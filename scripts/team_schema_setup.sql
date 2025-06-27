-- This script is now re-runnable. It will drop old objects before creating new ones.

-- Drop foreign key constraints first to avoid dependency errors.
-- This block is now corrected to only drop foreign keys (constraint_type = 'R').
BEGIN
  FOR c IN (SELECT constraint_name, table_name FROM user_constraints WHERE constraint_type = 'R' AND table_name IN ('COMPLAINTS', 'ESCALATIONS', 'RESPONSE_LOGS'))
  LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' DROP CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/

-- Drop tables (ignore errors if they don't exist)
BEGIN EXECUTE IMMEDIATE 'DROP TABLE response_logs'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE escalations'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE complaints'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE users'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE departments'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -942 THEN RAISE; END IF; END;
/

-- Drop sequences
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE user_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE dept_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE comp_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE esc_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE resp_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE complaint_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

-- Create all objects from scratch

-- USERS Table (Corrected typo 'deaprtment' -> 'department')
CREATE TABLE users (
    user_id         NUMBER PRIMARY KEY,
    full_name       VARCHAR2(100) NOT NULL,
    email           VARCHAR2(100) UNIQUE NOT NULL,
    password        VARCHAR2(100),
    phone_number    VARCHAR2(20),
    role            VARCHAR2(20),
    department      VARCHAR2(10)
);

-- DEPARTMENTS Table
CREATE TABLE departments (
    department_id   NUMBER PRIMARY KEY,
    department_name VARCHAR2(100) UNIQUE,
    description     VARCHAR2(500)
);

-- COMPLAINTS Table (Added 'department_id' and 'title' which were missing)
CREATE TABLE complaints (
    complaint_id      NUMBER PRIMARY KEY,
    title             VARCHAR2(200),
    description       CLOB,
    submitted_by      NUMBER,
    department_id     NUMBER,
    status            VARCHAR2(30),
    priority_level    VARCHAR2(20),
    submission_date   DATE DEFAULT SYSDATE,
    resolution_date   DATE,
    escalated         VARCHAR2(10)
);

-- ESCALATIONS Table
CREATE TABLE escalations (
    escalation_id       NUMBER PRIMARY KEY,
    complaint_id        NUMBER,
    from_department_id  NUMBER,
    to_department_id    NUMBER,
    escalated_by        NUMBER,
    escalation_reason   VARCHAR2(500),
    escalation_date     DATE DEFAULT SYSDATE
);

-- RESPONSE_LOGS Table
CREATE TABLE response_logs (
    log_id          NUMBER PRIMARY KEY,
    complaint_id    NUMBER,
    responded_by    NUMBER,
    response_text   CLOB,
    response_date   DATE DEFAULT SYSDATE
);

-- SEQUENCES
CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE comp_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE complaint_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE esc_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE resp_seq START WITH 1 INCREMENT BY 1;

-- FOREIGN KEYS
ALTER TABLE complaints ADD CONSTRAINT fk_complaint_user FOREIGN KEY (submitted_by) REFERENCES users(user_id);
ALTER TABLE complaints ADD CONSTRAINT fk_complaint_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_from_dept FOREIGN KEY (from_department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_to_dept FOREIGN KEY (to_department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_user FOREIGN KEY (escalated_by) REFERENCES users(user_id);
ALTER TABLE response_logs ADD CONSTRAINT fk_response_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id);
ALTER TABLE response_logs ADD CONSTRAINT fk_response_user FOREIGN KEY (responded_by) REFERENCES users(user_id);

-- Final message to confirm script completion
SELECT 'Schema setup complete.' AS status FROM DUAL;
/
