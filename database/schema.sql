CREATE DATABASE IF NOT EXISTS gojo;
USE gojo;
-- Creating Superadmin Table
CREATE TABLE IF NOT EXISTS superadmin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    remember_token VARCHAR(255)
);

-- Inserting superadmin example (please hash the password in real use)
INSERT INTO superadmin (username, password, email, remember_token)
VALUES ('superadmin', 'hashed_password', 'admin@example.com', NULL);

-- Creating Hospitals Table
CREATE TABLE IF NOT EXISTS hospitals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(255) NOT NULL UNIQUE,
    hospital_address VARCHAR(255) NOT NULL
);

-- Creating Hospital Representatives Table
CREATE TABLE IF NOT EXISTS hospital_representatives (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT,  -- Foreign Key to hospitals table
    rep_name VARCHAR(255) NOT NULL,
    rep_gender ENUM('Male', 'Female', 'Other') NOT NULL,
    rep_phone VARCHAR(10) NOT NULL UNIQUE,
    rep_email VARCHAR(255) NOT NULL UNIQUE,
    rep_username VARCHAR(100) NOT NULL UNIQUE,
    rep_password VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME NULL,
    created_by_superadmin_id INT,  -- ID of superadmin who created the record
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_superadmin_id) REFERENCES superadmin(id) ON DELETE CASCADE
);

-- Creating Admins Table
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    rep_id INT,  -- Foreign Key to hospital_representatives table
    admin_name VARCHAR(255) NOT NULL,
    admin_gender ENUM('Male', 'Female', 'Other') NOT NULL,
    admin_address VARCHAR(255) DEFAULT NULL,
    admin_phone VARCHAR(10) NOT NULL,
    admin_email VARCHAR(255) NOT NULL,
    admin_username VARCHAR(100) NOT NULL UNIQUE,
    admin_password VARCHAR(255) NOT NULL,
    department VARCHAR(255) DEFAULT NULL,
    is_active TINYINT(1) DEFAULT 0,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rep_id) REFERENCES hospital_representatives(id) ON DELETE CASCADE
);

-- Creating Staff Members Table
CREATE TABLE IF NOT EXISTS staff_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT,  -- Foreign Key to admins table
    role ENUM('Receptionist', 'Nurse', 'Doctor') NOT NULL,
    department VARCHAR(100),
    full_name VARCHAR(255) NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(10) NOT NULL,
    age INT NOT NULL,
    address VARCHAR(255) NOT NULL,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 0,
    can_login TINYINT(1) NOT NULL DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins(id),
    INDEX (admin_id)
);

-- Creating Patients Table
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT,  -- Foreign Key to hospitals table
    created_by_staff_id INT,  -- Foreign Key to staff_members table
    full_name VARCHAR(255) NOT NULL,
    age INT NOT NULL,
    gender ENUM('Male', 'Female', 'Other') NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(10) NOT NULL,
    address VARCHAR(255) NOT NULL,
    rfid_uid VARCHAR(50) UNIQUE,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_staff_id) REFERENCES staff_members(id) ON DELETE CASCADE,
    INDEX (hospital_id),
    INDEX (created_by_staff_id)
);

-- Creating Consultancy Records Table
CREATE TABLE IF NOT EXISTS consultancy_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,  -- Foreign Key to patients table
    doctor_id INT,  -- Foreign Key to staff_members table (Doctor)
    chief_complaint TEXT,
    diagnosis TEXT,
    prescription TEXT,
    additional_notes TEXT,
    appointment_datetime DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES staff_members(id) ON DELETE CASCADE
);

-- Creating Patient Vitals Table
CREATE TABLE IF NOT EXISTS patient_vitals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT,  -- Foreign Key to patients table
    recorded_by_staff_id INT,  -- Foreign Key to staff_members table
    temperature FLOAT,
    bp_systolic INT,
    bp_diastolic INT,
    pulse INT,
    respiratory_rate INT,
    sp_o2 FLOAT,
    weight FLOAT,
    height FLOAT,
    blood_sugar INT,
    pain_score INT,
    additional_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (recorded_by_staff_id) REFERENCES staff_members(id) ON DELETE CASCADE,
    INDEX (patient_id),
    INDEX (recorded_by_staff_id)
);

-- Creating Password Resets Table
CREATE TABLE IF NOT EXISTS password_resets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_type ENUM('superadmin', 'hospital_rep', 'admin', 'staff') NOT NULL,
    user_email VARCHAR(255) NOT NULL,
    otp_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME NOT NULL,
    is_used TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX (user_email),
    INDEX (expires_at)
);

-- Creating Staff Online Status Table
CREATE TABLE IF NOT EXISTS staff_online_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    staff_member_id INT,  -- Foreign Key to staff_members table
    is_online TINYINT(1) NOT NULL DEFAULT 0,
    last_seen DATETIME NULL,
    FOREIGN KEY (staff_member_id) REFERENCES staff_members(id) ON DELETE CASCADE
);

-- Creating Patient Insurance Details Table
CREATE TABLE IF NOT EXISTS patient_insurance_details (
    patient_id INT,  -- Foreign Key to patients table
    has_insurance ENUM('no', 'yes', 'cashless') DEFAULT 'no',
    insurance_provider VARCHAR(255),
    insurance_policy_number VARCHAR(100),
    policy_start_date DATE,
    policy_expiry_date DATE,
    PRIMARY KEY (patient_id),
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE
);


ALTER TABLE hospital_representatives
ADD COLUMN rep_address VARCHAR(255);

ALTER TABLE patients
ADD COLUMN emergency_contact_name VARCHAR(255),
ADD COLUMN emergency_contact_relation ENUM('spouse','parent','child','sibling','friend','other'),
ADD COLUMN emergency_contact_phone VARCHAR(10);

ALTER TABLE patients
ADD COLUMN aadhar_number VARCHAR(12) UNIQUE;


ALTER TABLE patients
ADD COLUMN id_proof_type VARCHAR(255);

ALTER TABLE patients
ADD COLUMN id_proof_number VARCHAR(255);

-- upto here there is normalization------------- 

ALTER TABLE hospitals
ADD COLUMN hospital_mode ENUM('ENTERPRISE','STANDARD') NOT NULL DEFAULT 'STANDARD',
ADD COLUMN is_active TINYINT(1) DEFAULT 1;

CREATE TABLE IF NOT EXISTS hr_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,

    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(15),

    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,

    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);


ALTER TABLE hospital_representatives 
DROP INDEX rep_email,
DROP INDEX rep_phone;

ALTER TABLE hospital_representatives
ADD UNIQUE KEY uq_rep_email_hospital (hospital_id, rep_email),
ADD UNIQUE KEY uq_rep_phone_hospital (hospital_id, rep_phone);
ALTER TABLE hospitals ADD INDEX idx_hosp_mode (hospital_mode);
ALTER TABLE hospital_representatives ADD INDEX idx_rep_hospital (hospital_id);
ALTER TABLE hr_users ADD INDEX idx_hr_hospital (hospital_id);
ALTER TABLE hospitals DROP INDEX hospital_name;
ALTER TABLE hospitals ADD UNIQUE KEY uq_hosp_name_addr (hospital_name, hospital_address);
ALTER TABLE admins ADD COLUMN hospital_id INT NOT NULL AFTER rep_id;
ALTER TABLE admins ADD CONSTRAINT fk_admin_hospital FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE;



-- HR Managers Table
CREATE TABLE IF NOT EXISTS hr_managers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hospital_id INT NOT NULL,
    hr_name VARCHAR(100) NOT NULL,
    hr_gender ENUM('Male', 'Female', 'Other') NOT NULL,
    hr_email VARCHAR(100) UNIQUE NOT NULL,
    hr_phone VARCHAR(15) NOT NULL,
    hr_username VARCHAR(50) UNIQUE NOT NULL,
    hr_password VARCHAR(255) NOT NULL,
    created_by_rep_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id),
    FOREIGN KEY (created_by_rep_id) REFERENCES hospital_representatives(id)
);

-- Departments Table
CREATE TABLE IF NOT EXISTS departments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    hospital_id INT NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_by_hr_id INT NOT NULL,
    created_on TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id),
    FOREIGN KEY (created_by_hr_id) REFERENCES hr_managers(id)
);



ALTER TABLE admins
ADD COLUMN department_id INT NULL AFTER hospital_id;
ALTER TABLE staff_members
ADD COLUMN department_id INT NULL AFTER admin_id;
ALTER TABLE admins
ADD CONSTRAINT fk_admin_department
FOREIGN KEY (department_id) REFERENCES departments(id)
ON DELETE SET NULL;
ALTER TABLE staff_members
ADD CONSTRAINT fk_staff_department
FOREIGN KEY (department_id) REFERENCES departments(id)
ON DELETE SET NULL;
ALTER TABLE departments
ADD UNIQUE KEY uq_dept_hosp (hospital_id, department_name);

ALTER TABLE admins DROP COLUMN department;
ALTER TABLE staff_members DROP COLUMN department;
ALTER TABLE hospital_representatives
MODIFY hospital_id INT NOT NULL;
ALTER TABLE patients
MODIFY hospital_id INT NOT NULL;
ALTER TABLE departments
MODIFY created_by_hr_id INT NULL;
DROP TABLE hr_users;
--
ALTER TABLE staff_members
ADD COLUMN rfid_uid VARCHAR(50) UNIQUE NULL AFTER username;
 
 
 -- ------------------------------alteration
 
 ALTER TABLE staff_members
ADD COLUMN can_do_reception TINYINT(1) NOT NULL DEFAULT 0,
ADD COLUMN can_do_nursing   TINYINT(1) NOT NULL DEFAULT 0;

CREATE TABLE IF NOT EXISTS pharmacy_admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,

    full_name VARCHAR(255) NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,

    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,

    is_active TINYINT(1) NOT NULL DEFAULT 1,
    can_login TINYINT(1) NOT NULL DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    created_by_hr_id INT NULL,

    UNIQUE KEY uq_pharmacy_user_hosp (hospital_id, username),
    UNIQUE KEY uq_pharmacy_email_hosp (hospital_id, email),
    UNIQUE KEY uq_pharmacy_phone_hosp (hospital_id, phone),

    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_hr_id) REFERENCES hr_managers(id) ON DELETE SET NULL
);

 DROP TABLE IF EXISTS pharmacy_admins;

CREATE TABLE IF NOT EXISTS pharmacy_admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,

    full_name VARCHAR(255) NOT NULL,
    gender ENUM('Male','Female','Other') NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(15) NOT NULL,

    username VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,

    is_active TINYINT(1) NOT NULL DEFAULT 1,
    can_login TINYINT(1) NOT NULL DEFAULT 1,
    last_login DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    created_by_hr_id INT NULL,

    UNIQUE KEY uq_pharm_user_hosp  (hospital_id, username),
    UNIQUE KEY uq_pharm_email_hosp (hospital_id, email),
    UNIQUE KEY uq_pharm_phone_hosp (hospital_id, phone),

    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_hr_id) REFERENCES hr_managers(id) ON DELETE SET NULL
);


ALTER TABLE staff_members MODIFY COLUMN role 
ENUM('Receptionist','Nurse','Doctor','Receptionist + Nurse') NOT NULL;
ALTER TABLE staff_members ADD COLUMN staff_pin VARCHAR(128) NULL;


SELECT id, username, role, can_login FROM staff_members WHERE username='receptionist';
SELECT password FROM staff_members WHERE username='receptionist';


ALTER TABLE staff_members 
CHANGE staff_pin staff_pin_hash VARCHAR(255) NULL;

-- PHARMACY MODULE (ADD-ON)
-- =========================

-- 1) Vendor / Wholesaler master
CREATE TABLE IF NOT EXISTS pharmacy_vendors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  vendor_name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255),
  address VARCHAR(255),
  gstin VARCHAR(20),
  dl_no VARCHAR(50),

  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_vendor_hosp_name (hospital_id, vendor_name),
  INDEX idx_vendor_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

-- 2) HSN / Tax master
CREATE TABLE IF NOT EXISTS pharmacy_hsn_tax (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  hsn_code VARCHAR(20) NOT NULL,
  tax_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  description VARCHAR(255),

  UNIQUE KEY uq_hsn_hosp (hospital_id, hsn_code),
  INDEX idx_hsn_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);

-- 3) Product master
CREATE TABLE IF NOT EXISTS pharmacy_products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,

  product_name VARCHAR(255) NOT NULL,
  generic_name VARCHAR(255),
  brand_name VARCHAR(255),

  hsn_id INT NULL,
  unit VARCHAR(50),               -- tab, strip, bottle etc.
  pack_size VARCHAR(50),          -- 10, 15, 60ml etc.
  reorder_level INT NOT NULL DEFAULT 0,

  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_prod_hosp_name (hospital_id, product_name),
  INDEX idx_prod_hosp (hospital_id),
  INDEX idx_prod_hsn (hsn_id),

  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (hsn_id) REFERENCES pharmacy_hsn_tax(id) ON DELETE SET NULL
);

-- 4) Stock batches (pharmacy MUST track batch + expiry)
CREATE TABLE IF NOT EXISTS pharmacy_stock_batches (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  product_id INT NOT NULL,

  batch_no VARCHAR(100) NOT NULL,
  expiry_date DATE NULL,

  qty_on_hand INT NOT NULL DEFAULT 0,

  purchase_rate DECIMAL(10,2) DEFAULT 0.00,
  mrp DECIMAL(10,2) DEFAULT 0.00,
  selling_price DECIMAL(10,2) DEFAULT 0.00,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_batch (hospital_id, product_id, batch_no),
  INDEX idx_batch_hosp (hospital_id),
  INDEX idx_batch_prod (product_id),
  INDEX idx_batch_expiry (expiry_date),

  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE CASCADE
);

-- 5) Stock ledger (audit trail)
CREATE TABLE IF NOT EXISTS pharmacy_stock_ledger (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NULL,

  txn_type ENUM('OPENING','PURCHASE','SALE','PURCHASE_RETURN','SALE_RETURN','ADJUSTMENT') NOT NULL,
  ref_table VARCHAR(50) NULL,
  ref_id BIGINT NULL,

  qty_in INT NOT NULL DEFAULT 0,
  qty_out INT NOT NULL DEFAULT 0,

  note VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_led_hosp (hospital_id),
  INDEX idx_led_prod (product_id),
  INDEX idx_led_batch (batch_id),
  INDEX idx_led_type (txn_type),

  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE CASCADE,
  FOREIGN KEY (batch_id) REFERENCES pharmacy_stock_batches(id) ON DELETE SET NULL
);

-- 6) Purchases (from vendor)
CREATE TABLE IF NOT EXISTS pharmacy_purchases (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  vendor_id INT NOT NULL,

  invoice_no VARCHAR(100),
  invoice_date DATE NULL,

  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  grand_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  created_by_pharmacy_admin_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_pur_hosp (hospital_id),
  INDEX idx_pur_vendor (vendor_id),

  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (vendor_id) REFERENCES pharmacy_vendors(id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_pharmacy_admin_id) REFERENCES pharmacy_admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_purchase_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  purchase_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NULL,

  batch_no VARCHAR(100) NOT NULL,
  expiry_date DATE NULL,
  qty INT NOT NULL,

  purchase_rate DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  mrp DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  selling_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,

  line_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  INDEX idx_pi_purchase (purchase_id),
  FOREIGN KEY (purchase_id) REFERENCES pharmacy_purchases(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE RESTRICT,
  FOREIGN KEY (batch_id) REFERENCES pharmacy_stock_batches(id) ON DELETE SET NULL
);

-- 7) Sales (to patient / walk-in)
CREATE TABLE IF NOT EXISTS pharmacy_sales (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,

  patient_id INT NULL,            -- optional: walk-in is NULL
  bill_no VARCHAR(100),
  bill_date DATETIME DEFAULT CURRENT_TIMESTAMP,

  subtotal DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  tax_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  grand_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  created_by_pharmacy_admin_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_sale_hosp (hospital_id),
  INDEX idx_sale_patient (patient_id),

  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE SET NULL,
  FOREIGN KEY (created_by_pharmacy_admin_id) REFERENCES pharmacy_admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_sale_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sale_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NULL,

  qty INT NOT NULL,
  selling_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  line_total DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  INDEX idx_si_sale (sale_id),
  FOREIGN KEY (sale_id) REFERENCES pharmacy_sales(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE RESTRICT,
  FOREIGN KEY (batch_id) REFERENCES pharmacy_stock_batches(id) ON DELETE SET NULL
);

-- 8) Returns / Credit notes
CREATE TABLE IF NOT EXISTS pharmacy_purchase_returns (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  purchase_id BIGINT NOT NULL,
  reason VARCHAR(255),
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_pr_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (purchase_id) REFERENCES pharmacy_purchases(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pharmacy_purchase_return_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  purchase_return_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NULL,
  qty INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  FOREIGN KEY (purchase_return_id) REFERENCES pharmacy_purchase_returns(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE RESTRICT,
  FOREIGN KEY (batch_id) REFERENCES pharmacy_stock_batches(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_sale_returns (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  sale_id BIGINT NOT NULL,
  reason VARCHAR(255),
  total_amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_sr_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (sale_id) REFERENCES pharmacy_sales(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pharmacy_sale_return_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sale_return_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  batch_id INT NULL,
  qty INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0.00,

  FOREIGN KEY (sale_return_id) REFERENCES pharmacy_sale_returns(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES pharmacy_products(id) ON DELETE RESTRICT,
  FOREIGN KEY (batch_id) REFERENCES pharmacy_stock_batches(id) ON DELETE SET NULL
);

-- 9) Mapping layer for vendor imports
CREATE TABLE IF NOT EXISTS pharmacy_import_templates (
  id INT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  vendor_id INT NULL,
  template_name VARCHAR(100) NOT NULL,
  file_type ENUM('CSV','XLSX') NOT NULL DEFAULT 'CSV',
  header_row INT NOT NULL DEFAULT 1,      -- 1-based
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  UNIQUE KEY uq_template (hospital_id, template_name),
  INDEX idx_tpl_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (vendor_id) REFERENCES pharmacy_vendors(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_import_mappings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  template_id INT NOT NULL,

  canonical_field VARCHAR(50) NOT NULL,   -- ex: product_name, batch_no, expiry_date, qty, mrp, purchase_rate
  vendor_column_name VARCHAR(255) NOT NULL, -- ex: "Item Name", "Batch", "EXP", "QTY"
  transform_rule VARCHAR(255) NULL,       -- optional: "date_ddmmyyyy", "strip_spaces"
  is_required TINYINT(1) NOT NULL DEFAULT 0,

  UNIQUE KEY uq_map (template_id, canonical_field),
  INDEX idx_map_template (template_id),

  FOREIGN KEY (template_id) REFERENCES pharmacy_import_templates(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pharmacy_import_runs (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  hospital_id INT NOT NULL,
  template_id INT NOT NULL,
  file_name VARCHAR(255),
  total_rows INT NOT NULL DEFAULT 0,
  success_rows INT NOT NULL DEFAULT 0,
  failed_rows INT NOT NULL DEFAULT 0,
  created_by_pharmacy_admin_id INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_run_hosp (hospital_id),
  FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
  FOREIGN KEY (template_id) REFERENCES pharmacy_import_templates(id) ON DELETE RESTRICT,
  FOREIGN KEY (created_by_pharmacy_admin_id) REFERENCES pharmacy_admins(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS pharmacy_import_errors (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  run_id BIGINT NOT NULL,
  row_no INT NOT NULL,
  error_message VARCHAR(255) NOT NULL,
  raw_json JSON NULL,

  INDEX idx_err_run (run_id),
  FOREIGN KEY (run_id) REFERENCES pharmacy_import_runs(id) ON DELETE CASCADE
);

-- Create Beds Table with Department, Floor, and Room Information
CREATE TABLE IF NOT EXISTS beds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,  -- Foreign Key to hospitals table
    department_id INT NOT NULL,  -- Foreign Key to departments table
    floor_number INT NOT NULL,  -- For multi-floor support
    room_number VARCHAR(50) NOT NULL,  -- For room identification
    bed_number VARCHAR(50) NOT NULL,  -- For bed identification
    is_occupied TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = Free, 1 = Occupied
    patient_id INT NULL,  -- Foreign Key to patients table (NULL if bed is free)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE SET NULL
);

--Table for structured medication data in consultancy
CREATE TABLE IF NOT EXISTS consultancy_medications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    consultancy_id INT NOT NULL,
    medicine_id INT NULL,
    medicine_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    duration VARCHAR(100),
    quantity_prescribed INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (consultancy_id) REFERENCES consultancy_records(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES pharmacy_products(id) ON DELETE SET NULL
);

-- Table for pharmacy prescriptions sent from doctor
CREATE TABLE IF NOT EXISTS pharmacy_prescriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    hospital_id INT NOT NULL,
    prescription_status ENUM('PENDING', 'IN_PROGRESS', 'READY', 'DISPENSED', 'CANCELLED') DEFAULT 'PENDING',
    notes TEXT,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id),
    FOREIGN KEY (doctor_id) REFERENCES staff(id),
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id)
);

-- Table for detailed prescription items
CREATE TABLE IF NOT EXISTS pharmacy_prescription_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NULL,
    medicine_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    duration VARCHAR(100),
    quantity_prescribed INT NOT NULL,
    quantity_dispensed INT DEFAULT 0,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    total_price DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prescription_id) REFERENCES pharmacy_prescriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES pharmacy_products(id) ON DELETE SET NULL
);

-- Add index for better performance
CREATE INDEX idx_consultancy_medications_consultancy_id ON consultancy_medications(consultancy_id);
CREATE INDEX idx_pharmacy_prescriptions_status ON pharmacy_prescriptions(prescription_status);
CREATE INDEX idx_pharmacy_prescriptions_patient ON pharmacy_prescriptions(patient_id);

-- Drop the existing table with wrong foreign key
DROP TABLE IF EXISTS pharmacy_prescriptions;

-- Create with correct foreign key reference to staff_members
CREATE TABLE IF NOT EXISTS pharmacy_prescriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    hospital_id INT NOT NULL,
    prescription_status ENUM('PENDING', 'IN_PROGRESS', 'READY', 'DISPENSED', 'CANCELLED') DEFAULT 'PENDING',
    notes TEXT,
    total_amount DECIMAL(10,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES staff_members(id) ON DELETE CASCADE,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE
);
-- Drop the existing table with wrong foreign key
DROP TABLE IF EXISTS pharmacy_prescription_details;

-- Create with correct foreign key reference
CREATE TABLE IF NOT EXISTS pharmacy_prescription_details (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prescription_id INT NOT NULL,
    medicine_id INT NULL,
    medicine_name VARCHAR(255) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    duration VARCHAR(100),
    quantity_prescribed INT NOT NULL,
    quantity_dispensed INT DEFAULT 0,
    unit_price DECIMAL(10,2) DEFAULT 0.00,
    total_price DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prescription_id) REFERENCES pharmacy_prescriptions(id) ON DELETE CASCADE,
    FOREIGN KEY (medicine_id) REFERENCES pharmacy_products(id) ON DELETE SET NULL
);

-- Add indexes for better performance
CREATE INDEX idx_consultancy_medications_consultancy_id ON consultancy_medications(consultancy_id);
CREATE INDEX idx_pharmacy_prescriptions_status ON pharmacy_prescriptions(prescription_status);
CREATE INDEX idx_pharmacy_prescriptions_patient ON pharmacy_prescriptions(patient_id);
CREATE INDEX idx_pharmacy_prescriptions_doctor ON pharmacy_prescriptions(doctor_id);
CREATE INDEX idx_pharmacy_prescriptions_hospital ON pharmacy_prescriptions(hospital_id);

-- Create Beds Table with Department, Floor, and Room Information
CREATE TABLE IF NOT EXISTS beds (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,  -- Foreign Key to hospitals table
    department_id INT NOT NULL,  -- Foreign Key to departments table
    floor_number INT NOT NULL,  -- For multi-floor support
    room_number VARCHAR(50) NOT NULL,  -- For room identification
    bed_number VARCHAR(50) NOT NULL,  -- For bed identification
    is_occupied TINYINT(1) NOT NULL DEFAULT 0,  -- 0 = Free, 1 = Occupied
    patient_id INT NULL,  -- Foreign Key to patients table (NULL if bed is free)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (hospital_id) REFERENCES hospitals(id) ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE SET NULL
);

-- 1. Add bed assignment columns to patients table
ALTER TABLE patients 
ADD COLUMN admission_type ENUM('outpatient', 'inpatient') DEFAULT 'outpatient' AFTER rfid_uid,
ADD COLUMN department_id INT NULL AFTER admission_type,
ADD COLUMN assigned_bed_id INT NULL AFTER department_id;

-- 2. Add foreign key constraints for normalization
ALTER TABLE patients 
ADD CONSTRAINT fk_patient_department 
FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL;

ALTER TABLE patients 
ADD CONSTRAINT fk_patient_bed 
FOREIGN KEY (assigned_bed_id) REFERENCES beds(id) ON DELETE SET NULL;

-- 3. Add indexes for better performance
ALTER TABLE patients 
ADD INDEX idx_patient_department (department_id),
ADD INDEX idx_patient_bed (assigned_bed_id);

-- 4. Add is_active column to departments for better management
ALTER TABLE departments 
ADD COLUMN is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER description;

-- 5. Add unique constraint to beds to prevent duplicate bed assignments
ALTER TABLE beds 
ADD UNIQUE KEY uq_bed_location (hospital_id, department_id, floor_number, room_number, bed_number);

-- 6. Add indexes to beds table for better performance
ALTER TABLE beds 
ADD INDEX idx_bed_hospital (hospital_id),
ADD INDEX idx_bed_department (department_id),
ADD INDEX idx_bed_occupied (is_occupied),
ADD INDEX idx_bed_patient (patient_id);

-- 7. Add index for active departments
ALTER TABLE departments 
ADD INDEX idx_dept_active (hospital_id, is_active);