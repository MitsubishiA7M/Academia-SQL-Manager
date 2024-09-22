This project involves the design and implementation of a university course management database system. It manages student enrollments, course information, and program data while maintaining consistency through SQL views, functions, and constraints. The system ranks students based on course performance, enforces prerequisite checks, and supports program and course enrollments with integrity via foreign keys and validation rules.

# proj1_finished.sql:
This file contains various SQL views, functions, and stored procedures related to student course management at a university.
It includes functions for ranking students within courses based on their marks, handling students' course enrollments, and filtering courses based on prerequisites.
Several views are created to join various tables like students, subjects, courses, program_enrolments, and course_enrolments.
One of the views ranks students within each course (q9) based on marks, and a related function q9 is provided to retrieve these ranks for a specific student (unswid).
There is also a procedure for managing program enrollments and course enrollments, aiming to maintain consistency across semesters.

# schema.sql:
This file defines the database schema and relationships for a university system. It includes detailed CREATE TABLE and ALTER TABLE statements.
The tables created include students, subjects, courses, program_enrolments, semesters, and others related to course management.
Foreign key relationships are enforced between tables like students, subjects, courses, acad_object_groups, and semesters, ensuring data integrity.
Constraints, such as primary keys and foreign keys, are defined to ensure the relationships between different entities are respected.
Additional integrity checks (e.g., for subject unit of credit) are applied to maintain data consistency.
