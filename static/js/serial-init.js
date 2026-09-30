document.addEventListener("DOMContentLoaded", () => {
  const modalEl = document.getElementById("serialPortModal");
  if (!modalEl) return;

  const serialModal = new bootstrap.Modal(modalEl);
  const connectBtn = document.getElementById("connectSerialBtn");

  let port = null;
  let reader = null;
  let writer = null;
  let keepReading = false;

  window.__latestUid = null;
  window.__serialPortOpen = false;

  function webSerialSupported() {
    return "serial" in navigator;
  }

  async function sendCommand(cmd) {
    if (!port?.writable) return;
    try {
      if (!writer) writer = port.writable.getWriter();
      const encoder = new TextEncoder();
      await writer.write(encoder.encode(cmd + "\n"));
    } catch (e) {
      console.warn("Serial write failed:", e);
    }
  }

  async function openPort(selectedPort) {
    if (port) return;

    await selectedPort.open({
      baudRate: 115200,
      dataBits: 8,
      stopBits: 1,
      parity: "none",
      flowControl: "none"
    });

    try {
      await selectedPort.setSignals({
        dataTerminalReady: false,
        requestToSend: false
      });
    } catch (e) {
      console.warn("setSignals not supported:", e);
    }

    port = selectedPort;
    keepReading = true;
    window.__serialPortOpen = true;

    // expose command helpers
    window.__serialSendCommand = sendCommand;
    window.__serialScanOn = () => sendCommand("SCAN_ON");
    window.__serialScanOff = () => sendCommand("SCAN_OFF");

    readLoop();
  }

  async function readLoop() {
    if (!port?.readable) return;

    const decoder = new TextDecoder();
    reader = port.readable.getReader();
    let buffer = "";

    try {
      while (keepReading) {
        const { value, done } = await reader.read();
        if (done) break;
        if (!value) continue;

        const text = decoder.decode(value, { stream: true });
        buffer += text;

        const lines = buffer.split(/\r?\n/);
        buffer = lines.pop() || "";

        for (let line of lines) {
          line = line.trim();
          if (!line) continue;

          console.log("SERIAL LINE:", line);

          if (/^[0-9A-F]{8,32}$/i.test(line)) {
            window.__latestUid = line.toUpperCase();
            console.log("✅ UID DETECTED:", window.__latestUid);
          }
        }
      }
    } catch (e) {
      console.error("Serial read error:", e);
    } finally {
      try { reader.releaseLock(); } catch {}
      reader = null;
    }
  }

  async function closePort() {
    keepReading = false;

    try {
      await sendCommand("SCAN_OFF");
    } catch {}

    try {
      if (reader) await reader.cancel();
    } catch {}

    try {
      if (writer) {
        writer.releaseLock();
        writer = null;
      }
    } catch {}

    try {
      if (port) await port.close();
    } catch {}

    reader = null;
    writer = null;
    port = null;
    window.__latestUid = null;
    window.__serialPortOpen = false;
    window.__serialSendCommand = null;
    window.__serialScanOn = null;
    window.__serialScanOff = null;
  }

  async function checkConnection() {
    if (!webSerialSupported()) {
      console.warn("Web Serial not supported. Use Chrome/Edge desktop.");
      return;
    }

    if (!window.isSecureContext) {
      console.warn("Web Serial requires HTTPS or localhost. Current:", location.origin);
      serialModal.show();
      return;
    }

    const nonce = document.querySelector('meta[name="login-nonce"]')?.content || "";
    const last = sessionStorage.getItem("seen_login_nonce");

    if (nonce && nonce !== last) {
      sessionStorage.setItem("seen_login_nonce", nonce);
      serialModal.show();
      return;
    }

    try {
      const ports = await navigator.serial.getPorts();
      if (ports.length) {
        await openPort(ports[0]);
        serialModal.hide();
        return;
      }
    } catch (e) {
      console.warn("Auto-open failed:", e);
    }

    serialModal.show();
  }

  connectBtn.addEventListener("click", async () => {
    if (!webSerialSupported()) {
      alert("Web Serial not supported. Use Chrome/Edge on desktop.");
      return;
    }

    if (!window.isSecureContext) {
      alert("Web Serial requires HTTPS or http://localhost.");
      return;
    }

    connectBtn.disabled = true;
    connectBtn.textContent = "Select Device...";

    try {
      const selectedPort = await navigator.serial.requestPort();
      connectBtn.textContent = "Opening...";
      await openPort(selectedPort);
      serialModal.hide();
    } catch (e) {
      console.error("Serial connect failed:", e);
      alert("Could not connect. Please select the RFID device again.");
    } finally {
      connectBtn.disabled = false;
      connectBtn.textContent = "Connect";
    }
  });

  if (navigator.serial?.addEventListener) {
    navigator.serial.addEventListener("disconnect", (event) => {
      if (event.target === port) {
        console.warn("Serial device disconnected");
        closePort();
        serialModal.show();
      }
    });
  }

  window.__disconnectWebSerial = closePort;

  window.addEventListener("beforeunload", closePort);

  checkConnection();
});