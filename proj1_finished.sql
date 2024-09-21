------------------------------------------------------
-- COMP9311 24T1 Project 1 
-- SQL and PL/pgSQL 
-- Template
-- Name:GAOYUAN FAN
-- zID:z5540213
------------------------------------------------------

-- Q1:

create or replace view Q1(subject_code)
as

Select subjects.code from subjects
Join orgunits on subjects.offeredby = orgunits.id
Join orgunit_types on orgunits.utype = orgunit_types.id
Where orgunit_types.name  = 'School'
And orgunits.longname like '%Information%'
And subjects.code like '____7%';

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q2:

create or replace view Q2(course_id)
as

SELECT courses.id 
FROM courses
JOIN classes ON classes.course = courses.id
JOIN class_types ON classes.ctype = class_types.id
JOIN subjects ON courses.subject = subjects.id
WHERE subjects.code LIKE 'COMP%'
GROUP BY courses.id
HAVING SUM(CASE WHEN class_types.name IN ('Lecture', 'Laboratory') THEN 1 ELSE 0 END) = COUNT(DISTINCT classes.id)
AND COUNT(DISTINCT class_types.name) = 2;

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q3:

create or replace view q3_1
as
select courses.id, people.name
from courses
join course_staff on course_staff.course = courses.id
join staff on course_staff.staff = staff.id
join people on staff.id = people.id
where people.title like 'Prof'
group by courses.id, people.name
;

create or replace view q3_2
as
select id as courses_id from q3_1
group by courses_id
HAVING COUNT(id) >= 2;
;

create or replace view Q3(unsw_id)
as

SELECT DISTINCT people.unswid
FROM people
JOIN students ON students.id = people.id
JOIN course_enrolments ON course_enrolments.student = students.id
JOIN courses ON course_enrolments.course = courses.id
JOIN semesters ON semesters.id = courses.semester
JOIN q3_2 ON q3_2.courses_id = course_enrolments.course
WHERE CAST(people.unswid AS TEXT) LIKE '320%'
AND semesters.year between 2008 and 2012
GROUP BY people.unswid
HAVING COUNT(DISTINCT q3_2.courses_id) >= 5;

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q4:

create or replace view q4_all
as
select 
    courses.id as course_id,
    round(avg(course_enrolments.mark), 2) as avg_mark,
    semesters.term,
    rank() over(partition by semesters.term, orgunits.id order by round(avg(course_enrolments.mark), 2) desc) as rank
from courses
join semesters on courses.semester = semesters.id
join course_enrolments on course_enrolments.course = courses.id
join students on course_enrolments.student = students.id
join people on students.id = people.id
join subjects on courses.subject = subjects.id
join orgunits on subjects.offeredby = orgunits.id
join orgunit_types on orgunits.utype = orgunit_types.id
where (course_enrolments.grade = 'DN' or course_enrolments.grade = 'HD')
and semesters.year = '2012'
and orgunit_types.name = 'Faculty'
group by courses.id, semesters.term, orgunits.id;

create or replace view q4
as
select 
    course_id,
    avg_mark
from q4_all
as course_rankings
where rank = 1;

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q5:

create or replace view q5_1
as
select courses.id, people.given
from courses
join semesters on courses.semester = semesters.id and semesters.year between 2005 and 2015
join course_enrolments on course_enrolments.course = courses.id
join course_staff on course_staff.course = courses.id
join staff on course_staff.staff = staff.id
join people on staff.id = people.id and people.title = 'Prof'
where courses.id in (
    select course
    from course_enrolments
    group by course
    having count(course_enrolments.student) > 500
)
group by courses.id, people.given;

create or replace view q5
as
select q5_1.id as course_id, string_agg(q5_1.given, '; ' order by q5_1.given) as staff_name
from q5_1
group by q5_1.id
having count(distinct q5_1.given) >= 2;

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q6:

create or replace view q6_1
as
select 
    rooms.id as room_id, 
    subjects.code as subject_code, 
    classes.id as classes_id
from rooms
join classes on classes.room = rooms.id
join courses on classes.course = courses.id
join subjects on courses.subject = subjects.id
join semesters on courses.semester = semesters.id and semesters.year = 2012
group by rooms.id, subjects.code, classes.id
;

create or replace view q6_2 as
select
    q6_1.room_id,
    q6_1.subject_code,
    q6_1.classes_id
from q6_1
join (
    select room_id,
        count(*) as usage_count
    from q6_1
    group by room_id
    order by count(*) desc
    limit 1
) 
as max_usage on q6_1.room_id = max_usage.room_id;

create or replace view q6 as
select
    room_id,
    subject_code
from (
    select
        room_id,
        subject_code,
        rank() over (partition by room_id order by count(subject_code) desc) as rank
    from q6_2
    group by room_id, subject_code
) as ranked_subjects
where rank = 1;

--... SQL statements, possibly using other views/functions defined by you ...
;


-- Q7:

DROP VIEW IF EXISTS q7_1;
CREATE VIEW q7_1 AS
-- SELECT 
--     people.unswid, 
--     orgunits.id AS orgunits_id, 
--     program_enrolments.program AS programs_id, 
--     programs.uoc AS programs_uoc, 
--     SUM(subjects.uoc) AS sum_subjects_uoc
-- FROM 
--     students
-- JOIN people ON people.id = students.id
-- JOIN program_enrolments ON program_enrolments.student = students.id
-- JOIN programs ON programs.id = program_enrolments.program
-- JOIN orgunits ON orgunits.id = programs.offeredby
-- JOIN course_enrolments ON course_enrolments.student = students.id
-- JOIN courses ON courses.id = course_enrolments.course AND courses.semester = program_enrolments.semester
-- JOIN subjects ON subjects.id = courses.subject
-- WHERE 
--     course_enrolments.mark >= 50
-- GROUP BY 
--     people.unswid, orgunits.id, program_enrolments.program, programs.uoc
-- HAVING 
--     SUM(subjects.uoc) >= programs.uoc;
select students.id as student_id, people.unswid, orgunits.id as orgunits_id, program_enrolments.program as programs_id, courses.semester, subjects.uoc as subjects_uoc, programs.uoc as programs_uoc
from students
join people on people.id = students.id
join program_enrolments on program_enrolments.student = students.id
join programs on programs.id = program_enrolments.program 
join orgunits on orgunits.id = programs.offeredby
join course_enrolments on course_enrolments.student = students.id
join courses on courses.id = course_enrolments.course and courses.semester = program_enrolments.semester
join subjects on subjects.id = courses.subject 
where course_enrolments.mark >= 50
order by student_id;

DROP VIEW IF EXISTS q7_2;
CREATE VIEW q7_2 AS
select unswid, orgunits_id, programs_id, programs_uoc, sum(subjects_uoc) as sum_subjects_uoc
from q7_1
group by unswid, orgunits_id, programs_id, programs_uoc
having sum(subjects_uoc) >= programs_uoc;

DROP VIEW IF EXISTS q7_3;
CREATE VIEW q7_3 AS
select q7_2.unswid, q7_2.orgunits_id
from q7_2
join people on q7_2.unswid = people.unswid
join students on students.id = people.id
join program_enrolments on program_enrolments.program = q7_2.programs_id and program_enrolments.student = students.id
join semesters on semesters.id = program_enrolments.semester
group by q7_2.unswid, orgunits_id
having max(semesters.ending) - min(semesters.starting) < 1000
and count(distinct q7_2.programs_id) >= 2;

CREATE OR REPLACE VIEW q7 AS
select q7_3.unswid as student_id, q7_2.programs_id as program_id
from q7_2 join q7_3 on q7_2.unswid = q7_3.unswid
and q7_2.orgunits_id = q7_3.orgunits_id;


-- Q8:

-- 工作人员和能查到担任职位的条目，条目数量正确
DROP VIEW IF EXISTS q8_1;
CREATE VIEW q8_1 AS
SELECT  people.unswid, staff.id as staff_id, staff_roles.name, orgunits.id as orgunits_id
FROM people
JOIN staff ON staff.id = people.id
JOIN affiliations ON affiliations.staff = staff.id
join orgunits on affiliations.orgunit = orgunits.id
JOIN staff_roles ON affiliations.role = staff_roles.id
GROUP BY people.unswid, staff.id, staff_roles.name, orgunits_id
order by unswid;
-- 

-- 以前在同一组织中担任过三个或以上职位的工作人员
DROP VIEW IF EXISTS q8_2;
CREATE VIEW q8_2 AS
SELECT unswid, staff_id, orgunits_id, COUNT(*) as occurrences
FROM q8_1
GROUP BY unswid, staff_id, orgunits_id
HAVING COUNT(*) >= 3;
-- 

-- 2012年所有担任Course Convenor的staff_id和所有≥75的分数
DROP VIEW IF EXISTS q8_3;
CREATE VIEW q8_3 AS
SELECT 
    STAFF.id AS staff_id, 
    courses.id AS course_id, 
    course_enrolments.mark
FROM staff
JOIN people ON staff.id = people.id
JOIN course_staff ON course_staff.staff = staff.id
JOIN staff_roles ON course_staff.role = staff_roles.id AND staff_roles.id = '1870'
JOIN courses ON course_staff.course = courses.id
JOIN course_enrolments ON course_enrolments.course = courses.id
JOIN semesters ON courses.semester = semesters.id AND semesters.year = '2012'
-- WHERE course_enrolments.mark >= 75
WHERE course_enrolments.mark is not NULL
GROUP BY STAFF.id, courses.id, course_enrolments.mark
ORDER BY staff_id;
-- 

-- 所有符合条件的staff
DROP VIEW IF EXISTS q8_4;
CREATE VIEW q8_4 AS
select unswid, q8_2.staff_id as f_staff_id, q8_3.course_id, q8_3.mark
from q8_2
inner join q8_3 on q8_2.staff_id = q8_3.staff_id;
-- 

-- 计算hdn_rate
-- 分子是所有选了这个staff_id是CC的courses.id的学生，他这些course都≥75
DROP VIEW IF EXISTS q8_5;
CREATE VIEW q8_5 AS
SELECT 
    q8_4.f_staff_id,
    COUNT(*) AS mark_75
FROM q8_4
WHERE q8_4.mark >= 75
GROUP BY q8_4.f_staff_id;
--

-- 分母是这个staff_id是CC的所有courses的所有学生
-- CREATE OR REPLACE VIEW q8_5 AS
-- SELECT people.unswid, courses.id,q8_4.f_staff_id, course_enrolments.mark
-- from courses
-- join course_enrolments on course_enrolments.course = courses.id
-- join students on course_enrolments.student = students.id
-- join people on students.id = people.id
-- right join q8_4 on courses.id = q8_4.course_id
-- group by people.unswid, courses.id,f_staff_id, course_enrolments.mark
-- order by f_staff_id;

-- CREATE OR REPLACE VIEW q8_6 AS
-- SELECT 
--     f_staff_id, 
--     COUNT(*) AS entry_count
-- FROM 
--     q8_5
-- GROUP BY 
--     f_staff_id
-- ORDER BY 
--     f_staff_id;

DROP VIEW IF EXISTS q8_6;
CREATE VIEW q8_6 AS
SELECT 
    q8_4.f_staff_id, 
    COUNT(*) AS entry_count
FROM 
    courses
JOIN 
    course_enrolments ON course_enrolments.course = courses.id
JOIN 
    students ON course_enrolments.student = students.id
JOIN 
    people ON students.id = people.id
RIGHT JOIN 
    q8_4 ON courses.id = q8_4.course_id
GROUP BY 
    q8_4.f_staff_id
ORDER BY 
    q8_4.f_staff_id;
-- 
-- sum_id从这里取
DROP VIEW IF EXISTS q8_sum_id;
CREATE VIEW q8_sum_id AS
SELECT 
    q8_1.unswid as staff_unswid,
    q8_1.staff_id, 
    COUNT(*) AS sum_count
FROM 
    q8_1
WHERE 
    q8_1.staff_id IN (SELECT staff_id FROM q8_2)
GROUP BY 
    q8_1.unswid, q8_1.staff_id;
-- 

-- 最终
DROP VIEW IF EXISTS q8;
CREATE VIEW q8 AS
SELECT 
    q8_sum_id.unswid AS staff_id, 
    q8_sum_id.sum_count AS sum_roles, 
    ROUND((CAST(q8_5.mark_75 AS NUMERIC) / NULLIF(q8_6.entry_count, 0)), 2) AS hdn_rate
FROM 
    q8_sum_id
JOIN 
    q8_5 ON q8_sum_id.staff_id = q8_5.f_staff_id
JOIN 
    q8_6 ON q8_sum_id.staff_id = q8_6.f_staff_id
WHERE 
    q8_6.entry_count > 0
ORDER BY 
    hdn_rate DESC
LIMIT 21;
-- DROP VIEW IF EXISTS Q8;
-- CREATE VIEW Q8 AS
-- SELECT 
--     ranked_results.staff_id, 
--     ranked_results.sum_roles, 
--     ranked_results.hdn_rate
-- FROM (
--     SELECT 
--         q8_sum_id.staff_unswid AS staff_id, 
--         q8_sum_id.sum_count AS sum_roles, 
--         ROUND((CAST(q8_5.mark_75 AS NUMERIC) / NULLIF(q8_6.entry_count, 0)), 2) AS hdn_rate,
--         RANK() OVER (ORDER BY ROUND((CAST(q8_5.mark_75 AS NUMERIC) / NULLIF(q8_6.entry_count, 0)), 2) DESC) AS rank
--     FROM 
--         q8_sum_id
--     JOIN 
--         q8_5 ON q8_sum_id.staff_id = q8_5.f_staff_id
--     JOIN 
--         q8_6 ON q8_sum_id.staff_id = q8_6.f_staff_id
--     WHERE 
--         q8_6.entry_count > 0
-- ) AS ranked_results
-- WHERE 
--     ranked_results.rank <= 20;


-- Q9

CREATE or replace view q9_1
as
SELECT 
    people.unswid, 
    subjects.code, 
    course_enrolments.mark, 
    RANK() OVER (PARTITION BY courses.id ORDER BY course_enrolments.mark DESC) AS rank_in_course
FROM subjects
JOIN courses ON courses.subject = subjects.id
JOIN course_enrolments ON course_enrolments.course = courses.id
JOIN students ON course_enrolments.student = students.id
JOIN people ON people.id = students.id
WHERE 
    course_enrolments.mark IS NOT NULL
    AND EXISTS (
        SELECT 1 
        FROM subjects prereq_subjects 
        WHERE 
            subjects._prereq IS NOT NULL
            AND subjects._prereq LIKE prereq_subjects.code || '%'
            AND substr(subjects.code, 1, 4) = substr(prereq_subjects.code, 1, 4) 
    );
    -- OR subjects.code = 'FINS5542';

CREATE OR REPLACE FUNCTION q9(q9_1_unswid INTEGER)
RETURNS SETOF TEXT AS $$
DECLARE
    result RECORD;
    output TEXT;
BEGIN
    FOR result IN
        SELECT code, rank_in_course
        FROM q9_1
        WHERE q9_1.unswid = q9_1_unswid
    LOOP
        output := result.code || ' ' || result.rank_in_course::TEXT;
        RETURN NEXT output;
    END LOOP;

    IF NOT FOUND THEN
        output := 'WARNING: Invalid Student Input [' || q9_1_unswid::TEXT || ']';
        RETURN NEXT output;
    END IF;
END;
$$ language plpgsql;


-- Q10

create or replace view q10_1 as
select program_enrolments.student, program_enrolments.program, course_enrolments.course
from program_enrolments join students on program_enrolments.student = students.id
join semesters on program_enrolments.semester = semesters.id
join course_enrolments on course_enrolments.student = students.id
join courses on course_enrolments.course = courses.id
where program_enrolments.semester = courses.semester;

create or replace view q10_2 as
select q10_1.*, subjects.uoc 
from q10_1 join course_enrolments on (q10_1.student, q10_1.course) = (course_enrolments.student, course_enrolments.course)
join courses on q10_1.course = courses.id
join subjects on courses.subject = subjects.id
where course_enrolments.mark is not null;

create or replace view q10_3 as
select student, program, sum(uoc)
from q10_2 
group by student, program;

create or replace view q10_4 as
select q10_1.*, subjects.uoc, course_enrolments.mark
from q10_1 join course_enrolments on (q10_1.student, q10_1.course) = (course_enrolments.student, course_enrolments.course)
join courses on q10_1.course = courses.id
join subjects on courses.subject = subjects.id
where course_enrolments.grade not in ('SY', 'XE', 'T', 'PE')
and course_enrolments.mark is not null;

create or replace view q10_5 as
select student, program, sum(uoc * mark)
from q10_4 
group by student, program;

CREATE OR REPLACE FUNCTION Q10(unswid INTEGER) RETURNS SETOF TEXT AS $$
DECLARE
    student_record RECORD;
    wam NUMERIC;
    output_line TEXT;
BEGIN
    -- Iterate through each program the student is enrolled in
    FOR student_record IN
        SELECT q10_1.student, q10_1.program, SUM(q10_4.uoc * q10_4.mark) AS total_marks, SUM(q10_4.uoc) AS total_uoc
        FROM q10_1
        JOIN q10_4 ON q10_1.student = q10_4.student AND q10_1.program = q10_4.program AND q10_1.course = q10_4.course
        WHERE q10_1.student = unswid
        GROUP BY q10_1.student, q10_1.program
    LOOP
        -- Calculate WAM for the current program
        IF student_record.total_uoc > 0 THEN
            wam := ROUND((student_record.total_marks / student_record.total_uoc), 2);
            output_line := unswid || ' ' || student_record.program || ' ' || wam::TEXT;
        ELSE
            -- Handle case where no WAM is available
            output_line := unswid || ' ' || student_record.program || ' No WAM Available';
        END IF;
        
        RETURN NEXT output_line;
    END LOOP;

    -- Check if the student is enrolled in any programs
    IF NOT FOUND THEN
        RETURN NEXT 'WARNING: Invalid Student Input [' || unswid || ']';
    END IF;
END;
$$ LANGUAGE plpgsql;