# import serial

# _ser = None

# def connect_serial(port, baudrate=115200):
#     global _ser
#     try:
#         # 🔥 ALWAYS reset serial before connecting
#         if _ser and _ser.is_open:
#             _ser.close()

#         _ser = serial.Serial(port, baudrate, timeout=0.1)
#         print(f"SERIAL CONNECTED ON {port}")
#         return True
#     except Exception as e:
#         print("Serial connect error:", e)
#         _ser = None
#         return False


# def is_connected():
#     return _ser is not None and _ser.is_open


# def read_rfid():
#     if not is_connected():
#         return None

#     while _ser.in_waiting:
#         line = _ser.readline().decode(errors="ignore").strip()
#         if line.startswith("UID:"):
#             uid = line.replace("UID:", "")
#             print("RFID UID RECEIVED:", uid)
#             return uid
#     return None


# def close_serial():
#     global _ser
#     if _ser and _ser.is_open:
#         _ser.close()
#         print("SERIAL CLOSED")
#     _ser = None

import serial
import time
import re

_ser = None

UID_RE = re.compile(r"([0-9A-Fa-f]{8,})")  # match 8+ hex chars

def connect_serial(port, baudrate=115200):
    global _ser
    try:
        if _ser and _ser.is_open:
            _ser.close()

        _ser = serial.Serial(port, baudrate, timeout=0.2)
        _ser.reset_input_buffer()
        print(f"SERIAL CONNECTED ON {port}")
        return True
    except Exception as e:
        print("SERIAL CONNECT ERROR:", e)
        _ser = None
        return False


def is_connected():
    return _ser is not None and _ser.is_open


def read_rfid():
    if not is_connected():
        return None

    deadline = time.time() + 0.5
    buf = b""

    while time.time() < deadline:
        n = _ser.in_waiting
        if n:
            buf += _ser.read(n)
            text = buf.decode(errors="ignore")
            # debug
            if text.strip():
                print("SERIAL BUF:", repr(text[-200:]))

            m = UID_RE.search(text)
            if m:
                uid = m.group(1).upper()
                print("RFID UID RECEIVED:", uid)
                _ser.reset_input_buffer()
                return uid

        time.sleep(0.02)

    return None
def bytes_waiting():
    return _ser.in_waiting if is_connected() else 0


def close_serial():
    global _ser
    try:
        if _ser and _ser.is_open:
            _ser.close()
            print("SERIAL CLOSED")
    except:
        pass
    _ser = None
