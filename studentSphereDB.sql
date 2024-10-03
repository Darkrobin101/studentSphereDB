-- Create a New Database 
CREATE DATABASE studentSphereDB;
USE studentSphereDB;

-- Create Tables 
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    middle_name VARCHAR(50),
    gender VARCHAR(10),
    major_id INT,
    date_of_birth DATE,
    minor_id INT,
    age INT
);

CREATE TABLE ContactInfo (
    student_id INT PRIMARY KEY,
    school_email VARCHAR(100),
    personal_email VARCHAR(100),
    contact_number BIGINT,
    address VARCHAR(100),
    postal_code VARCHAR(10),
    city VARCHAR(50),
    province VARCHAR(50),
    country VARCHAR(50),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

CREATE TABLE EmergencyContact (
    student_id INT,
    contact_name VARCHAR(100),
    contact_phone BIGINT,
    PRIMARY KEY (student_id, contact_name),
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

CREATE TABLE Major (
    major_id INT PRIMARY KEY,
    major_name VARCHAR(50)
);

CREATE TABLE Minor (
    minor_id INT PRIMARY KEY,
    minor_name VARCHAR(50)
);

CREATE TABLE CourseInfo (
    course_id VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100),
    duration VARCHAR(50),
    credit_value FLOAT,
    instructor_name VARCHAR(100)
);

CREATE TABLE CourseGrade (
    student_id INT,
    course_id VARCHAR(10),
    component VARCHAR(50),
    score FLOAT,
    weight FLOAT,
    PRIMARY KEY (student_id, course_id, component),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES CourseInfo(course_id)
);

CREATE TABLE StudentGrades (
    student_id INT,
    course_id VARCHAR(10),
    course_grade FLOAT,
    PRIMARY KEY (student_id, course_id),
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (course_id) REFERENCES CourseInfo(course_id)
);

CREATE TABLE AcademicInfo (
    student_id INT PRIMARY KEY,
    current_year INT,
    credits_completed INT,
    credits_required INT,
    overall_grade FLOAT,
    FOREIGN KEY (student_id) REFERENCES Students(student_id)
);

-- SHOW OFF TABLES
SHOW TABLES;
select * from students;
select * from contactinfo;
select * from emergencycontact;
select * from major;
select * from minor;
select * from courseinfo;
select * from coursegrade;
select * from studentgrades;
select * from academicinfo;

-- Insert demo data into the tables
INSERT INTO Students VALUES (100007, "Prithvi", "Paturi", "Narayana", "Male", 1, "2004-10-24", 13, 23);

INSERT INTO ContactInfo VALUES (100007, "patu3136@mylaurier.ca", "prithvi.paturi@gmail.com", 6476152404, "47 Tarmack Drive", "L4E0E8", 'Richmond Hill', 'Ontario', "Canada");

INSERT INTO EmergencyContact (student_id, contact_name, contact_phone) VALUES (100007, "Zohib Ahmadi", "6477132997");

INSERT INTO Major VALUES (1, "Computer Science");
INSERT INTO Minor VALUES (13, "Mathematics");

INSERT INTO CourseInfo VALUES ("CP363", "Database Management", "Semester Long", 1.00, "Dr. Smith");
INSERT INTO CourseInfo VALUES ("PS204", "Psychology Of Prithvi Paturi", "Year Long", 1.00, "Shaun Gao");

INSERT INTO CourseGrade (student_id, course_id, component, score, weight) VALUES 
(100007, "CP363", "Midterm II", 76, 30),
(100007, "CP363", "Project Report", 80, 15),
(100007, "CP363", "Presentation", 100, 15),
(100007, "CP363", "Final Exam", 95, 40);

INSERT INTO AcademicInfo (student_id, current_year, credits_completed, credits_required, overall_grade) VALUES (100007, 1, 0, 20, 0);

-- Update student grades
INSERT INTO StudentGrades (student_id, course_id, course_grade)
SELECT
    cg.student_id,
    cg.course_id,
    ROUND(SUM(cg.score * cg.weight / 100), 2) AS overall_grade
FROM
    CourseGrade cg
GROUP BY
    cg.student_id,
    cg.course_id
ON DUPLICATE KEY UPDATE
    course_grade = VALUES(course_grade);

-- Update academic info with the overall grade
UPDATE AcademicInfo ai
SET ai.overall_grade = (
    SELECT AVG(sg.course_grade)
    FROM StudentGrades sg
    WHERE sg.student_id = ai.student_id
    GROUP BY sg.student_id
);

-- Query: Show student details along with major, minor, and GPA
SELECT
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS full_name,
    mj.major_name,
    mn.minor_name,
    ai.overall_grade
FROM
    Students s
LEFT JOIN
    Major mj ON s.major_id = mj.major_id
LEFT JOIN
    Minor mn ON s.minor_id = mn.minor_id
LEFT JOIN
    AcademicInfo ai ON s.student_id = ai.student_id;
