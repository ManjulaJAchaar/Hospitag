# Hospitag – Hospital Management & Pharmacy Billing System

A full-featured hospital management web application built with **Flask** and **MySQL**, with role-based portals for hospital staff, RFID-based patient tagging, bed management, and a complete pharmacy inventory & billing module.

![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.0-000000?logo=flask&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8-4479A1?logo=mysql&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Features

### Role-based portals
| Role | What they can do |
|------|------------------|
| **Super Admin** | Register hospitals and hospital administrators |
| **Hospital Admin** | Manage staff, track patients, view dashboards |
| **HR Manager** | Create departments, department admins and pharmacy admins; staff overview |
| **Doctor** | View assigned patients, consultancy records, manage schedules & emergency slots |
| **Receptionist / Nurse** | Register patients, record vitals, manage beds |
| **Pharmacy Admin** | Inventory, purchases, sales billing and returns |

### Hospital operations
- **RFID patient tagging** – read patient RFID cards over a serial connection (ESP32 / USB reader)
- **Bed management** – mark beds free / occupied, edit and track bed status
- **Doctor scheduling** – regular and emergency schedules, availability reports
- **Consultancy records** – patient visits, vitals and insurance details
- **Secure authentication** – hashed passwords, email OTP for password resets, online/offline staff status

### Pharmacy & billing
- Product catalogue with batches, expiry dates and **HSN tax codes**
- Purchases, sales (billing), purchase returns and sale returns
- Stock ledger with batch-level adjustments
- **Low-stock** and **near-expiry** alerts
- Vendor / wholesaler management
- **Excel import** of inventory with column mapping and error reports

---

## Tech Stack

- **Backend:** Python, Flask, Flask-Mail
- **Database:** MySQL (`mysql-connector-python`)
- **Frontend:** Jinja2 templates, HTML, CSS, JavaScript
- **Hardware:** PySerial (RFID reader)
- **Other:** openpyxl (Excel import), python-dotenv

---

## Project Structure

```
Hospitag/
├── app.py                 # Flask application (all routes)
├── config.py              # Reads settings from .env
├── serial_manager.py      # RFID serial-port helper
├── utils/
│   └── email_sender.py    # SMTP email helpers (OTP, account creation)
├── templates/             # Jinja2 HTML pages for every role
├── static/                # CSS, JS, uploaded staff photos
├── database/
│   └── schema.sql         # MySQL schema
├── samples/
│   └── pharmacy_inventory_sample.xlsx   # Sample file for the Excel import
├── requirements.txt
└── .env.example
```

---

## Getting Started

### Prerequisites
- Python 3.10+
- MySQL 8.x
- (Optional) An RFID reader connected over USB/serial

### 1. Clone the repository
```bash
git clone https://github.com/ManjulaJAchaar/Hospitag.git
cd Hospitag
```

### 2. Create a virtual environment and install dependencies
```bash
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS / Linux
pip install -r requirements.txt
```

### 3. Set up the database
```bash
mysql -u root -p < database/schema.sql
```
This creates the `gojo` database and all tables.

### 4. Configure environment variables
Copy `.env.example` to `.env` and fill in your values:
```env
SECRET_KEY=replace-with-a-long-random-string
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your-mysql-password
DB_NAME=gojo
EMAIL_USER=you@gmail.com
EMAIL_PASS=your-gmail-app-password
```
> For Gmail, create an **App Password** under Google Account → Security → App passwords.

### 5. Run the app
```bash
python app.py
```
Open **http://localhost:5000** in your browser.

---

## License

This project is licensed under the [MIT License](LICENSE).

## Author

**Manjula J Achaar** – [@ManjulaJAchaar](https://github.com/ManjulaJAchaar)
