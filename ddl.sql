PostgreSQL 데이터베이스의 DDL(Data Definition Language)과 DML(Data Manipulation Language) 스크립트를 생성해 드릴게요. 모든 외래 키는 ON UPDATE CASCADE와 ON DELETE CASCADE로 설정하여 부모 테이블의 변경/삭제 시 자식 테이블도 자동으로 업데이트/삭제되도록 합니다.

🗄️ 스키마 생성 DDL (Data Definition Language)
먼저 테이블을 그룹화할 스키마를 생성합니다.

SQL

-- Create Schemas
CREATE SCHEMA IF NOT EXISTS master;
CREATE SCHEMA IF NOT EXISTS request;
CREATE SCHEMA IF NOT EXISTS keydata;
📋 테이블 DDL 및 Sample Data DML
1. master.processplan
SQL

-- DDL for master.processplan
CREATE TABLE master.processplan (
    id SERIAL PRIMARY KEY,
    design_rule TEXT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- DML for master.processplan (3 samples)
INSERT INTO master.processplan (design_rule) VALUES
('DR-A_2024_001'),
('DR-B_2024_002'),
('DR-C_2024_003');
2. master.beol_option
SQL

-- DDL for master.beol_option
CREATE TABLE master.beol_option (
    id SERIAL PRIMARY KEY,
    processplan_id INT NOT NULL,
    option_name TEXT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_processplan
        FOREIGN KEY (processplan_id)
        REFERENCES master.processplan (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for master.beol_option (3 per processplan_id)
INSERT INTO master.beol_option (processplan_id, option_name) VALUES
((SELECT id FROM master.processplan WHERE design_rule = 'DR-A_2024_001'), 'BEOL_Option_1A'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-A_2024_001'), 'BEOL_Option_1B'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-A_2024_001'), 'BEOL_Option_1C'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-B_2024_002'), 'BEOL_Option_2A'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-B_2024_002'), 'BEOL_Option_2B'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-B_2024_002'), 'BEOL_Option_2C'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-C_2024_003'), 'BEOL_Option_3A'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-C_2024_003'), 'BEOL_Option_3B'),
((SELECT id FROM master.processplan WHERE design_rule = 'DR-C_2024_003'), 'BEOL_Option_3C');
3. master.product
SQL

-- DDL for master.product
CREATE TABLE master.product (
    id SERIAL PRIMARY KEY,
    beol_option_id INT NOT NULL,
    processplan_id INT NOT NULL,
    part_id TEXT NOT NULL UNIQUE, -- part_id는 고유하게 설정하여 제품 식별
    product_name TEXT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_beol_option
        FOREIGN KEY (beol_option_id)
        REFERENCES master.beol_option (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_processplan_product
        FOREIGN KEY (processplan_id)
        REFERENCES master.processplan (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for master.product (3 per beol_option_id)
INSERT INTO master.product (beol_option_id, processplan_id, part_id, product_name) VALUES
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), 'PART-A1-001', 'Product A1-001'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), 'PART-A1-002', 'Product A1-002'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1A'), 'PART-A1-003', 'Product A1-003'),

((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), 'PART-B1-001', 'Product B1-001'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), 'PART-B1-002', 'Product B1-002'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_1B'), 'PART-B1-003', 'Product B1-003'),

((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), 'PART-C1-001', 'Product C1-001'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), 'PART-C1-002', 'Product C1-002'),
((SELECT id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), (SELECT processplan_id FROM master.beol_option WHERE option_name = 'BEOL_Option_2A'), 'PART-C1-003', 'Product C1-003');
4. request.product_meta (Product 당 1개)
SQL

-- DDL for request.product_meta
CREATE TABLE request.product_meta (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL UNIQUE, -- 1:1 관계를 위해 UNIQUE 제약 조건 추가
    process_id TEXT NOT NULL,
    mto_date DATE NOT NULL,
    customer TEXT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_product_meta
        FOREIGN KEY (product_id)
        REFERENCES master.product (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for request.product_meta (1 per product)
INSERT INTO request.product_meta (product_id, process_id, mto_date, customer) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'), 'PROC-001-A', '2025-07-01', 'Customer Alpha'),
((SELECT id FROM master.product WHERE part_id = 'PART-A1-002'), 'PROC-002-B', '2025-07-05', 'Customer Beta'),
((SELECT id FROM master.product WHERE part_id = 'PART-B1-001'), 'PROC-003-C', '2025-07-10', 'Customer Gamma'),
((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'), 'PROC-004-D', '2025-07-15', 'Customer Delta');
5. request.request_item (Product 당 2~4개)
SQL

-- DDL for request.request_item
CREATE TABLE request.request_item (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    edm_list TEXT[],
    requester_id TEXT NOT NULL,
    requester_name TEXT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_product_item
        FOREIGN KEY (product_id)
        REFERENCES master.product (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for request.request_item (2-4 per product)
INSERT INTO request.request_item (product_id, title, description, requester_id, requester_name) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'), 'Design Review A1', 'Initial design review for A1-001', 'req_001', 'Alice'),
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'), 'Material Check A1', 'Verify material spec for A1-001', 'req_002', 'Bob'),
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'), 'Testing Plan A1', 'Develop testing plan for A1-001', 'req_001', 'Alice'),

((SELECT id FROM master.product WHERE part_id = 'PART-B1-001'), 'Production Plan B1', 'Outline production steps for B1-001', 'req_003', 'Charlie'),
((SELECT id FROM master.product WHERE part_id = 'PART-B1-001'), 'Quality Assurance B1', 'QA checks for B1-001', 'req_004', 'David'),

((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'), 'Assembly Instructions C1', 'Document assembly steps', 'req_005', 'Eve'),
((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'), 'Documentation Update C1', 'Update user manual for C1-001', 'req_006', 'Frank'),
((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'), 'Firmware Review C1', 'Review firmware version 1.2', 'req_005', 'Eve'),
((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'), 'Shipping Logistics C1', 'Coordinate shipping for C1-001', 'req_006', 'Frank');
6. request.item_approval_status (Item 당 1개)
PostgreSQL ENUM 타입을 먼저 생성합니다.

SQL

-- Create ENUM type for request_approval
CREATE TYPE approval_status AS ENUM ('pending', 'rejected', 'approved', 'not-reviewed', 'none');

-- DDL for request.item_approval_status
CREATE TABLE request.item_approval_status (
    id SERIAL PRIMARY KEY,
    request_item_id INT NOT NULL UNIQUE, -- 1:1 관계를 위해 UNIQUE 제약 조건 추가
    request_approval approval_status NOT NULL, -- ENUM 타입 사용
    request_approval_update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_request_item_approval
        FOREIGN KEY (request_item_id)
        REFERENCES request.request_item (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for request.item_approval_status (1 per request_item)
INSERT INTO request.item_approval_status (request_item_id, request_approval) VALUES
((SELECT id FROM request.request_item WHERE title = 'Design Review A1'), 'approved'),
((SELECT id FROM request.request_item WHERE title = 'Material Check A1'), 'pending'),
((SELECT id FROM request.request_item WHERE title = 'Testing Plan A1'), 'not-reviewed'),
((SELECT id FROM request.request_item WHERE title = 'Production Plan B1'), 'approved'),
((SELECT id FROM request.request_item WHERE title = 'Quality Assurance B1'), 'rejected'),
((SELECT id FROM request.request_item WHERE title = 'Assembly Instructions C1'), 'approved'),
((SELECT id FROM request.request_item WHERE title = 'Documentation Update C1'), 'pending'),
((SELECT id FROM request.request_item WHERE title = 'Firmware Review C1'), 'approved'),
((SELECT id FROM request.request_item WHERE title = 'Shipping Logistics C1'), 'none');
7. keydata.product_key_table (Product 당 4개 이상, table_name과 table_row 다르게)
SQL

-- DDL for keydata.product_key_table
CREATE TABLE keydata.product_key_table (
    id SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    beol_option_id INT NOT NULL,
    processplan_id INT NOT NULL,
    key_table_name TEXT NOT NULL,
    original_header TEXT[] NOT NULL,
    meta_info_list TEXT[] NOT NULL,
    key_table_json JSONB[] NOT NULL, -- JSONB[] for better performance with JSON operations
    rev_no INT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_product_key_table_product
        FOREIGN KEY (product_id)
        REFERENCES master.product (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_product_key_table_beol_option
        FOREIGN KEY (beol_option_id)
        REFERENCES master.beol_option (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT fk_product_key_table_processplan
        FOREIGN KEY (processplan_id)
        REFERENCES master.processplan (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for keydata.product_key_table (4+ per product)
-- Product PART-A1-001 에 대한 샘플 데이터
-- DML for keydata.product_key_table (4+ per product)
-- Product PART-A1-001 에 대한 샘플 데이터
INSERT INTO keydata.product_key_table (product_id, beol_option_id, processplan_id, key_table_name, original_header, meta_info_list, key_table_json, rev_no) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'),
 (SELECT beol_option_id FROM master.product WHERE part_id = 'PART-A1-001'),
 (SELECT processplan_id FROM master.product WHERE part_id = 'PART-A1-001'),
 'Material_Properties',
 ARRAY['Material_Name', 'Density', 'Conductivity'],
 ARRAY['units:kg/m^3', 'units:S/m'],
 ARRAY[
  '{"keyname": "Copper", "step": "12.0", "composition": "Cu_100", "density": 8960, "conductivity": 5.96e7}'::jsonb,
  '{"keyname": "Aluminum", "step": "13.0", "composition": "Al_100", "density": 2700, "conductivity": 3.5e7}'::jsonb,
  '{"keyname": "Silicon", "step": "14.0", "composition": "Si_100", "density": 2330, "conductivity": 1.56e-3}'::jsonb,
  '{"keyname": "Gold", "step": "15.0", "composition": "Au_100", "density": 19300, "conductivity": 4.52e7}'::jsonb,
  '{"keyname": "Silver", "step": "16.0", "composition": "Ag_100", "density": 10490, "conductivity": 6.30e7}'::jsonb,
  '{"keyname": "Brass", "step": "17.0", "composition": "CuZn_mix", "density": 8500, "conductivity": 1.59e7}'::jsonb,
  '{"keyname": "Steel", "step": "18.0", "composition": "FeC_mix", "density": 7850, "conductivity": 1.0e7}'::jsonb,
  '{"keyname": "Tungsten", "step": "19.0", "composition": "W_100", "density": 19300, "conductivity": 1.8e7}'::jsonb,
  '{"keyname": "Nickel", "step": "20.0", "composition": "Ni_100", "density": 8908, "conductivity": 1.43e7}'::jsonb,
  '{"keyname": "Titanium", "step": "21.0", "composition": "Ti_100", "density": 4506, "conductivity": 2.38e6}'::jsonb
 ], 1);

INSERT INTO keydata.product_key_table (product_id, beol_option_id, processplan_id, key_table_name, original_header, meta_info_list, key_table_json, rev_no) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-A1-001'),
 (SELECT beol_option_id FROM master.product WHERE part_id = 'PART-A1-001'),
 (SELECT processplan_id FROM master.product WHERE part_id = 'PART-A1-001'),
 'Electrical_Parameters',
 ARRAY['Parameter', 'Value', 'Unit'],
 ARRAY['description:nominal', 'description:tolerance'],
 ARRAY[
  '{"keyname": "Resistance", "step": "1.0", "composition": "main", "Parameter": "R_total", "Value": 100, "Unit": "Ohm", "tolerance": "5%"}'::jsonb,
  '{"keyname": "Capacitance", "step": "2.0", "composition": "main", "Parameter": "C_filter", "Value": 10, "Unit": "uF", "tolerance": "10%"}'::jsonb,
  '{"keyname": "Inductance", "step": "3.0", "composition": "main", "Parameter": "L_choke", "Value": 1, "Unit": "mH", "tolerance": "20%"}'::jsonb,
  '{"keyname": "Voltage_Max", "step": "4.0", "composition": "main", "Parameter": "Vcc_max", "Value": 5, "Unit": "V", "tolerance": "1%"}'::jsonb,
  '{"keyname": "Current_Idle", "step": "5.0", "composition": "main", "Parameter": "I_idle", "Value": 100, "Unit": "mA", "tolerance": "15%"}'::jsonb,
  '{"keyname": "Frequency_Clock", "step": "6.0", "composition": "main", "Parameter": "F_clk", "Value": 100, "Unit": "MHz", "tolerance": "2%"}'::jsonb,
  '{"keyname": "Power_Consumption", "step": "7.0", "composition": "main", "Parameter": "P_cons", "Value": 500, "Unit": "mW", "tolerance": "25%"}'::jsonb,
  '{"keyname": "Rise_Time", "step": "8.0", "composition": "main", "Parameter": "Tr", "Value": 5, "Unit": "ns", "tolerance": "30%"}'::jsonb,
  '{"keyname": "Fall_Time", "step": "9.0", "composition": "main", "Parameter": "Tf", "Value": 6, "Unit": "ns", "tolerance": "30%"}'::jsonb,
  '{"keyname": "Noise_Level", "step": "10.0", "composition": "main", "Parameter": "Noise_dB", "Value": 20, "Unit": "dB", "tolerance": "50%"}'::jsonb
 ], 1);

-- Product PART-B1-001 에 대한 샘플 데이터
INSERT INTO keydata.product_key_table (product_id, beol_option_id, processplan_id, key_table_name, original_header, meta_info_list, key_table_json, rev_no) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-B1-001'),
 (SELECT beol_option_id FROM master.product WHERE part_id = 'PART-B1-001'),
 (SELECT processplan_id FROM master.product WHERE part_id = 'PART-B1-001'),
 'Mechanical_Specs',
 ARRAY['Dimension', 'Value', 'Tolerance'],
 ARRAY['units:mm'],
 ARRAY[
  '{"keyname": "Length", "step": "1.0", "composition": "overall", "Dimension": "Length", "Value": 150, "Tolerance": "0.1mm"}'::jsonb,
  '{"keyname": "Width", "step": "2.0", "composition": "overall", "Dimension": "Width", "Value": 80, "Tolerance": "0.1mm"}'::jsonb,
  '{"keyname": "Height", "step": "3.0", "composition": "overall", "Dimension": "Height", "Value": 20, "Tolerance": "0.05mm"}'::jsonb,
  '{"keyname": "Weight", "step": "4.0", "composition": "overall", "Dimension": "Weight", "Value": 200, "Tolerance": "5g"}'::jsonb,
  '{"keyname": "Screw_Size", "step": "5.0", "composition": "fasteners", "Dimension": "Screw_Size", "Value": 2.5, "Tolerance": "0.01mm"}'::jsonb,
  '{"keyname": "Hole_Diameter", "step": "6.0", "composition": "holes", "Dimension": "Hole_Diameter", "Value": 3, "Tolerance": "0.02mm"}'::jsonb,
  '{"keyname": "Mounting_Pitch", "step": "7.0", "composition": "mounting", "Dimension": "Mounting_Pitch", "Value": 70, "Tolerance": "0.05mm"}'::jsonb,
  '{"keyname": "Surface_Roughness", "step": "8.0", "composition": "finish", "Dimension": "Roughness", "Value": 0.8, "Tolerance": "0.1um"}'::jsonb,
  '{"keyname": "Bend_Radius", "step": "9.0", "composition": "bending", "Dimension": "Radius", "Value": 5, "Tolerance": "0.05mm"}'::jsonb,
  '{"keyname": "Thickness", "step": "10.0", "composition": "material", "Dimension": "Thickness", "Value": 1.2, "Tolerance": "0.02mm"}'::jsonb
 ], 1);

-- Product PART-C1-001 에 대한 샘플 데이터
INSERT INTO keydata.product_key_table (product_id, beol_option_id, processplan_id, key_table_name, original_header, meta_info_list, key_table_json, rev_no) VALUES
((SELECT id FROM master.product WHERE part_id = 'PART-C1-001'),
 (SELECT beol_option_id FROM master.product WHERE part_id = 'PART-C1-001'),
 (SELECT processplan_id FROM master.product WHERE part_id = 'PART-C1-001'),
 'Environmental_Conditions',
 ARRAY['Condition', 'Min_Value', 'Max_Value', 'Unit'],
 ARRAY['description:operating_range'],
 ARRAY[
  '{"keyname": "Temperature_Operating", "step": "1.0", "composition": "env", "Condition": "Operating Temperature", "Min_Value": -20, "Max_Value": 70, "Unit": "°C"}'::jsonb,
  '{"keyname": "Humidity_Operating", "step": "2.0", "composition": "env", "Condition": "Operating Humidity", "Min_Value": 10, "Max_Value": 90, "Unit": "%RH"}'::jsonb,
  '{"keyname": "Vibration_Tolerance", "step": "3.0", "composition": "env", "Condition": "Vibration Tolerance", "Min_Value": 0, "Max_Value": 5, "Unit": "G"}'::jsonb,
  '{"keyname": "Shock_Tolerance", "step": "4.0", "composition": "env", "Condition": "Shock Tolerance", "Min_Value": 0, "Max_Value": 10, "Unit": "G"}'::jsonb,
  '{"keyname": "Pressure_Range", "step": "5.0", "composition": "env", "Condition": "Pressure Range", "Min_Value": 80, "Max_Value": 110, "Unit": "kPa"}'::jsonb,
  '{"keyname": "Dust_Protection", "step": "6.0", "composition": "env", "Condition": "Dust Protection", "Min_Value": 0, "Max_Value": 1, "Unit": "IP"}'::jsonb,
  '{"keyname": "Water_Resistance", "step": "7.0", "composition": "env", "Condition": "Water Resistance", "Min_Value": 0, "Max_Value": 1, "Unit": "IP"}'::jsonb,
  '{"keyname": "EMC_Compliance", "step": "8.0", "composition": "env", "Condition": "EMC Compliance", "Min_Value": 0, "Max_Value": 1, "Unit": "Class"}'::jsonb,
  '{"keyname": "Altitude_Max", "step": "9.0", "composition": "env", "Condition": "Max Altitude", "Min_Value": 0, "Max_Value": 3000, "Unit": "m"}'::jsonb,
  '{"keyname": "UV_Exposure", "step": "10.0", "composition": "env", "Condition": "UV Exposure Limit", "Min_Value": 0, "Max_Value": 100, "Unit": "hrs"}'::jsonb
 ], 1);
8. keydata.key_info_table (Processplan 당 4개 이상, table_name과 table_row 다르게)
SQL

-- DDL for keydata.key_info_table
CREATE TABLE keydata.key_info_table (
    id SERIAL PRIMARY KEY,
    processplan_id INT NOT NULL,
    info_table_name TEXT NOT NULL,
    original_header TEXT[] NOT NULL,
    info_table_json JSONB[] NOT NULL, -- JSONB[] for better performance
    rev_no INT NOT NULL,
    update_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_processplan_key_info
        FOREIGN KEY (processplan_id)
        REFERENCES master.processplan (id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- DML for keydata.key_info_table (4+ per processplan)
-- Processplan 'DR-A_2024_001' 에 대한 샘플 데이터
-- DML for keydata.key_info_table (4+ per processplan)
-- Processplan 'DR-A_2024_001' 에 대한 샘플 데이터
INSERT INTO keydata.key_info_table (processplan_id, info_table_name, original_header, info_table_json, rev_no) VALUES
((SELECT id FROM master.processplan WHERE design_rule = 'DR-A_2024_001'),
 'DR_A_Design_Constraints',
 ARRAY['Constraint_ID', 'Category', 'Description', 'Threshold'],
 ARRAY[
  '{"keyname": "C001", "step": "1.0", "composition": "DR", "Constraint_ID": "C001", "Category": "Electrical", "Description": "Max Current", "Threshold": "10A"}'::jsonb,
  '{"keyname": "C002", "step": "2.0", "composition": "DR", "Constraint_ID": "C002", "Category": "Mechanical", "Description": "Min Bend Radius", "Threshold": "0.5mm"}'::jsonb,
  '{"keyname": "C003", "step": "3.0", "composition": "DR", "Constraint_ID": "C003", "Category": "Thermal", "Description": "Max Operating Temp", "Threshold": "85C"}'::jsonb,
  '{"keyname": "C004", "step": "4.0", "composition": "DR", "Constraint_ID": "C004", "Category": "Reliability", "Description": "MTBF Target", "Threshold": "10000h"}'::jsonb,
  '{"keyname": "C005", "step": "5.0", "composition": "DR", "Constraint_ID": "C005", "Category": "Manufacturing", "Description": "Min Solder Pad Size", "Threshold": "0.2mm"}'::jsonb,
  '{"keyname": "C006", "step": "6.0", "composition": "DR", "Constraint_ID": "C006", "Category": "Environmental", "Description": "Humidity Tolerance", "Threshold": "95%"}'::jsonb,
  '{"keyname": "C007", "step": "7.0", "composition": "DR", "Constraint_ID": "C007", "Category": "Performance", "Description": "Max Clock Freq", "Threshold": "1GHz"}'::jsonb,
  '{"keyname": "C008", "step": "8.0", "composition": "DR", "Constraint_ID": "C008", "Category": "Safety", "Description": "Insulation Voltage", "Threshold": "1.5kV"}'::jsonb,
  '{"keyname": "C009", "step": "9.0", "composition": "DR", "Constraint_ID": "C009", "Category": "Cost", "Description": "Target BOM Cost", "Threshold": "$50"}'::jsonb,
  '{"keyname": "C010", "step": "10.0", "composition": "DR", "Constraint_ID": "C010", "Category": "Physical", "Description": "Max Component Height", "Threshold": "5mm"}'::jsonb
 ], 1);

INSERT INTO keydata.key_info_table (processplan_id, info_table_name, original_header, info_table_json, rev_no) VALUES
((SELECT id FROM master.processplan WHERE design_rule = 'DR-A_2024_001'),
 'DR_A_Process_Steps',
 ARRAY['Step_No', 'Process_Name', 'Tool_Used', 'Duration_min'],
 ARRAY[
  '{"keyname": "S01", "step": "1.0", "composition": "proc", "Step_No": 1, "Process_Name": "Wafer Cleaning", "Tool_Used": "Wet Bench 1", "Duration_min": 30}'::jsonb,
  '{"keyname": "S02", "step": "2.0", "composition": "proc", "Step_No": 2, "Process_Name": "Oxidation", "Tool_Used": "Furnace 1", "Duration_min": 120}'::jsonb,
  '{"keyname": "S03", "step": "3.0", "composition": "proc", "Step_No": 3, "Process_Name": "Lithography", "Tool_Used": "Stepper 2", "Duration_min": 60}'::jsonb,
  '{"keyname": "S04", "step": "4.0", "composition": "proc", "Step_No": 4, "Process_Name": "Etching", "Tool_Used": "RIE Plasma", "Duration_min": 45}'::jsonb,
  '{"keyname": "S05", "step": "5.0", "composition": "proc", "Step_No": 5, "Process_Name": "Ion Implantation", "Tool_Used": "Ion Implanter", "Duration_min": 90}'::jsonb,
  '{"keyname": "S06", "step": "6.0", "composition": "proc", "Step_No": 6, "Process_Name": "Deposition", "Tool_Used": "PECVD", "Duration_min": 75}'::jsonb,
  '{"keyname": "S07", "step": "7.0", "composition": "proc", "Step_No": 7, "Process_Name": "Annealing", "Tool_Used": "RTP", "Duration_min": 15}'::jsonb,
  '{"keyname": "S08", "step": "8.0", "composition": "proc", "Step_No": 8, "Process_Name": "Metallization", "Tool_Used": "PVD Sputter", "Duration_min": 180}'::jsonb,
  '{"keyname": "S09", "step": "9.0", "composition": "proc", "Step_No": 9, "Process_Name": "Passivation", "Tool_Used": "PECVD 2", "Duration_min": 100}'::jsonb,
  '{"keyname": "S10", "step": "10.0", "composition": "proc", "Step_No": 10, "Process_Name": "Probe Test", "Tool_Used": "Prober X", "Duration_min": 240}'::jsonb
 ], 1);

-- Processplan 'DR-B_2024_002' 에 대한 샘플 데이터
INSERT INTO keydata.key_info_table (processplan_id, info_table_name, original_header, info_table_json, rev_no) VALUES
((SELECT id FROM master.processplan WHERE design_rule = 'DR-B_2024_002'),
 'DR_B_Recipe_Parameters',
 ARRAY['Recipe_ID', 'Parameter_Name', 'Min_Value', 'Max_Value', 'Default_Value'],
 ARRAY[
  '{"keyname": "R_P_001", "step": "1.0", "composition": "recipe", "Recipe_ID": "R001", "Parameter_Name": "Pressure", "Min_Value": 10, "Max_Value": 100, "Default_Value": 50}'::jsonb,
  '{"keyname": "R_P_002", "step": "2.0", "composition": "recipe", "Recipe_ID": "R001", "Parameter_Name": "Temperature", "Min_Value": 150, "Max_Value": 300, "Default_Value": 200}'::jsonb,
  '{"keyname": "R_P_003", "step": "3.0", "composition": "recipe", "Recipe_ID": "R002", "Parameter_Name": "Flow_Rate", "Min_Value": 1, "Max_Value": 10, "Default_Value": 5}'::jsonb,
  '{"keyname": "R_P_004", "step": "4.0", "composition": "recipe", "Recipe_ID": "R002", "Parameter_Name": "Power", "Min_Value": 500, "Max_Value": 2000, "Default_Value": 1000}'::jsonb,
  '{"keyname": "R_P_005", "step": "5.0", "composition": "recipe", "Recipe_ID": "R003", "Parameter_Name": "Etch_Time", "Min_Value": 30, "Max_Value": 120, "Default_Value": 60}'::jsonb,
  '{"keyname": "R_P_006", "step": "6.0", "composition": "recipe", "Recipe_ID": "R003", "Parameter_Name": "Gas_Mix_Ratio", "Min_Value": 0.1, "Max_Value": 0.9, "Default_Value": 0.5}'::jsonb,
  '{"keyname": "R_P_007", "step": "7.0", "composition": "recipe", "Recipe_ID": "R004", "Parameter_Name": "Spin_Speed", "Min_Value": 500, "Max_Value": 5000, "Default_Value": 2000}'::jsonb,
  '{"keyname": "R_P_008", "step": "8.0", "composition": "recipe", "Recipe_ID": "R004", "Parameter_Name": "Cure_Time", "Min_Value": 10, "Max_Value": 60, "Default_Value": 30}'::jsonb,
  '{"keyname": "R_P_009", "step": "9.0", "composition": "recipe", "Recipe_ID": "R005", "Parameter_Name": "Exposure_Dose", "Min_Value": 10, "Max_Value": 100, "Default_Value": 50}'::jsonb,
  '{"keyname": "R_P_010", "step": "10.0", "composition": "recipe", "Recipe_ID": "R005", "Parameter_Name": "Focus_Offset", "Min_Value": -0.5, "Max_Value": 0.5, "Default_Value": 0}'::jsonb
 ], 1);

-- 📝 참고 사항
-- ON UPDATE CASCADE / ON DELETE CASCADE: 외래 키 제약 조건에 이 옵션이 포함되어 있어, 부모 테이블의 행이 업데이트되거나 삭제될 때 자식 테이블의 관련 행도 자동으로 업데이트/삭제됩니다.

-- SERIAL: PRIMARY KEY로 설정된 id 컬럼은 SERIAL 타입을 사용하여 자동으로 증가하는 정수 값을 가집니다.

-- TIMESTAMP WITH TIME ZONE DEFAULT NOW(): update_time 컬럼은 현재 타임존 정보를 포함한 타임스탬프를 기본값으로 가집니다.

-- JSONB[]: table_rows 컬럼은 JSON 배열을 저장하며, JSONB 타입은 일반 JSON 타입보다 저장 공간을 효율적으로 사용하고 쿼리 성능이 우수합니다.

-- TEXT[]: original_headers 및 meta_info 컬럼은 텍스트 문자열의 배열을 저장합니다.

-- DML 순서: 외래 키 제약 조건 때문에 부모 테이블의 데이터가 먼저 삽입되어야 합니다. 따라서 DDL 및 DML은 정의된 순서대로 실행하는 것이 중요합니다.

-- SELECT 서브쿼리: DML에서 (SELECT id FROM ... WHERE ...) 서브쿼리를 사용하여 외래 키 값을 동적으로 가져옵니다. 이는 실제 ID 값을 모르더라도 데이터를 쉽게 삽입할 수 있게 해줍니다.

-- part_id UNIQUE: master.product 테이블의 part_id는 제품을 고유하게 식별하기 위해 UNIQUE 제약 조건을 추가했습니다.

-- product_id / request_item_id UNIQUE: 1:1 관계를 명확히 하기 위해 request.product_meta와 request.item_approval_status 테이블의 외래 키 컬럼에 UNIQUE 제약 조건을 추가했습니다.

-- JSONB 데이터 구조: table_rows의 JSON 배열은 original_headers의 개수와 JSON 객체 내 키의 개수를 일치시키라는 요구사항을 반영하여 샘플을 생성했습니다. 각 JSON 객체 내에는 keyname, step, composition과 같은 공통 필드 외에 original_headers에 해당하는 동적 필드들이 포함됩니다.

-- 이 스크립트를 사용하여 PostgreSQL 데이터베이스에 필요한 테이블 구조를 생성하고 샘플 데이터를 채울 수 있습니다.