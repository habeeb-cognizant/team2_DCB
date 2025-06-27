-- Inserting Sample Data
BEGIN
  FOR c IN (SELECT constraint_name, table_name FROM user_constraints WHERE constraint_type = 'R' AND table_name IN ('COMPLAINTS', 'ESCALATIONS', 'RESPONSE_LOGS'))
  LOOP
    EXECUTE IMMEDIATE 'ALTER TABLE ' || c.table_name || ' DROP CONSTRAINT ' || c.constraint_name;
  END LOOP;
END;
/
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
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE user_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE dept_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE comp_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE complaint_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE esc_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP SEQUENCE resp_seq'; EXCEPTION WHEN OTHERS THEN IF SQLCODE != -2289 THEN RAISE; END IF; END;
/

-- Step 2: Re-create all tables, sequences, and constraints.
CREATE TABLE users (user_id NUMBER PRIMARY KEY NOT NULL, full_name VARCHAR2(100) NOT NULL, email VARCHAR2(100) UNIQUE NOT NULL, password VARCHAR2(100), phone_number VARCHAR2(20), role VARCHAR2(20), department VARCHAR2(50));
CREATE TABLE departments (department_id NUMBER PRIMARY KEY, department_name VARCHAR2(100) UNIQUE, description VARCHAR2(500));
CREATE TABLE complaints (complaint_id NUMBER PRIMARY KEY, title VARCHAR2(200), description CLOB, submitted_by NUMBER, department_id NUMBER, status VARCHAR2(30), priority_level VARCHAR2(20), submission_date DATE DEFAULT SYSDATE, resolution_date DATE, escalated VARCHAR2(10));
CREATE TABLE escalations (escalation_id NUMBER PRIMARY KEY, complaint_id NUMBER, from_department_id NUMBER, to_department_id NUMBER, escalated_by NUMBER, escalation_reason VARCHAR2(500), escalation_date DATE DEFAULT SYSDATE);
CREATE TABLE response_logs (log_id NUMBER PRIMARY KEY, complaint_id NUMBER, responded_by NUMBER, response_text CLOB, response_date DATE DEFAULT SYSDATE);
CREATE SEQUENCE user_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE dept_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE complaint_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE esc_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE resp_seq START WITH 1 INCREMENT BY 1;
ALTER TABLE complaints ADD CONSTRAINT fk_complaint_user FOREIGN KEY (submitted_by) REFERENCES users(user_id);
ALTER TABLE complaints ADD CONSTRAINT fk_complaint_dept FOREIGN KEY (department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_from_dept FOREIGN KEY (from_department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_to_dept FOREIGN KEY (to_department_id) REFERENCES departments(department_id);
ALTER TABLE escalations ADD CONSTRAINT fk_escalation_user FOREIGN KEY (escalated_by) REFERENCES users(user_id);
ALTER TABLE response_logs ADD CONSTRAINT fk_response_complaint FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id);
ALTER TABLE response_logs ADD CONSTRAINT fk_response_user FOREIGN KEY (responded_by) REFERENCES users(user_id);

-- Step 3: Insert rich sample data.
INSERT INTO departments VALUES (dept_seq.NEXTVAL, 'Technical Support', 'Handles all technical and software related issues.');
INSERT INTO departments VALUES (dept_seq.NEXTVAL, 'Billing Department', 'Handles all payment and subscription inquiries.');
INSERT INTO departments VALUES (dept_seq.NEXTVAL, 'Customer Relations', 'Handles general feedback and non-technical issues.');
INSERT INTO users VALUES (user_seq.NEXTVAL, 'John Doe', 'john.doe@example.com', 'pass123', '555-0101', 'User', 'IT');
INSERT INTO users VALUES (user_seq.NEXTVAL, 'Jane Smith', 'jane.smith@example.com', 'pass456', '555-0102', 'User', 'Finance');
INSERT INTO users VALUES (user_seq.NEXTVAL, 'Admin Alice', 'alice.admin@grievance.com', 'adminPass', '555-0103', 'Admin', 'Support');
INSERT INTO users VALUES (user_seq.NEXTVAL, 'Manager Mike', 'mike.manager@grievance.com', 'managerPass', '555-0104', 'Manager', 'Billing');
INSERT INTO complaints (complaint_id, title, description, submitted_by, department_id, status, priority_level) VALUES (complaint_seq.NEXTVAL, 'Website Login Not Working', 'I am unable to log in to the main website. It keeps saying "Invalid Credentials".', 1, 1, 'Pending', 'High');
INSERT INTO complaints (complaint_id, title, description, submitted_by, department_id, status, priority_level) VALUES (complaint_seq.NEXTVAL, 'Incorrect Invoice #INV-5582', 'My monthly subscription fee was supposed to be $50, but I was charged $75.', 2, 2, 'In Progress', 'High');
INSERT INTO complaints (complaint_id, title, description, submitted_by, department_id, status, priority_level, resolution_date) VALUES (complaint_seq.NEXTVAL, 'Suggestion for Dark Mode', 'The application would be much better with a dark mode option.', 1, 3, 'Resolved', 'Low', SYSDATE - 2);
INSERT INTO response_logs VALUES (resp_seq.NEXTVAL, 2, 4, 'Thank you for reaching out. I have assigned this to my team to investigate the billing discrepancy.', SYSDATE - 1);
INSERT INTO escalations VALUES (esc_seq.NEXTVAL, 3, 3, 1, 3, 'User suggestion forwarded to technical team for review.', SYSDATE-1);
COMMIT;

-- Step 4: Final verification of setup
SELECT 'DEPARTMENTS' as table_name, count(*) as row_count from departments
UNION ALL
SELECT 'USERS', count(*) from users
UNION ALL
SELECT 'COMPLAINTS', count(*) from complaints
UNION ALL
SELECT 'ESCALATIONS', count(*) from escalations
UNION ALL
SELECT 'RESPONSE_LOGS', count(*) from response_logs;


-- TEST CASES

-- Show all departments
SELECT * FROM departments ORDER BY department_id;
-- Show all users
SELECT * FROM users ORDER BY user_id;
-- Show all complaints
SELECT * FROM complaints ORDER BY complaint_id;
-- Show all escalations
SELECT * FROM escalations ORDER BY escalation_id;
-- Show all responses
SELECT * FROM response_logs ORDER BY log_id;

-- Test Case 1: Verify CREATE with JOIN
INSERT INTO complaints (complaint_id, title, description, submitted_by, department_id, status, priority_level)
VALUES (complaint_seq.NEXTVAL, 'Cannot Upload Profile Picture', 'The upload button gives a 500 server error when I try to upload a new profile picture.', 2, 1, 'Pending', 'Medium');
COMMIT;
-- Step 2: Verify creation by joining tables to see full details.
SELECT c.complaint_id, c.title, u.full_name AS submitted_by_user, d.department_name AS assigned_department
FROM complaints c JOIN users u ON c.submitted_by = u.user_id JOIN departments d ON c.department_id = d.department_id
WHERE c.title = 'Cannot Upload Profile Picture';

-- Test Case 2: Verify UPDATE and Response Logging
SELECT * FROM complaints WHERE complaint_id = 2;
SELECT * FROM response_logs WHERE complaint_id = 2;
-- Step 2: Simulate the backend resolving the complaint.
UPDATE complaints SET status = 'Resolved', resolution_date = SYSDATE WHERE complaint_id = 2;
INSERT INTO response_logs (log_id, complaint_id, responded_by, response_text) VALUES (resp_seq.NEXTVAL, 2, 4, 'The billing error has been corrected and a refund has been issued.');
COMMIT;
-- Step 3: Verify the "after" state.
SELECT status, resolution_date FROM complaints WHERE complaint_id = 2;
SELECT count(*) as response_count FROM response_logs WHERE complaint_id = 2;

-- Test Case 3: Verify Complaint Escalation
SELECT complaint_id, status, department_id FROM complaints WHERE complaint_id = 1;
-- Step 2: Simulate escalating the complaint to the Billing department.
INSERT INTO escalations (escalation_id, complaint_id, from_department_id, to_department_id, escalated_by, escalation_reason) VALUES (esc_seq.NEXTVAL, 1, 1, 2, 3, 'User confirmed issue is related to payment method, not a technical bug.');
UPDATE complaints SET department_id = 2, status = 'Escalated', escalated = 'Yes' WHERE complaint_id = 1;
COMMIT;
-- Step 3: Verify the complaint was successfully escalated.
SELECT status, department_id, escalated FROM complaints WHERE complaint_id = 1;
SELECT from_department_id, to_department_id, escalation_reason FROM escalations WHERE complaint_id = 1;

-- Test Case 4: Verify DELETE and check for "Orphaned Records"
SELECT * FROM complaints WHERE complaint_id = 3;
SELECT * FROM escalations WHERE complaint_id = 3;
-- Step 2: Simulate deleting the related records and then the main complaint.
DELETE FROM escalations WHERE complaint_id = 3;
DELETE FROM complaints WHERE complaint_id = 3;
COMMIT;
-- Step 3: Verify both records are now gone.
SELECT * FROM complaints WHERE complaint_id = 3;
SELECT * FROM escalations WHERE complaint_id = 3;

-- Test Case 5: Negative Test (Unique Email Constraint)
SELECT * FROM users WHERE email = 'john.doe@example.com';
-- Step 2: Attempt to create a NEW user with the SAME email. This should FAIL.
INSERT INTO users (user_id, full_name, email, password, phone_number, role, department)
VALUES (user_seq.NEXTVAL, 'Another John', 'john.doe@example.com', 'newpass', '555-9999', 'User', 'Marketing');
-- Step 3: The test PASSES if Step 2 produced a unique constraint error.
SELECT count(*) FROM users;