#3.1-1
select name_student, date_attempt, result
from
    attempt inner join student using(student_id)
    inner join subject using(subject_id)
where name_subject = 'Основы баз данных'
order by result desc

#3.1-2
select name_subject, count(attempt_id) as Количество, round(avg(result),2) as Среднее 
from
    attempt right join subject using(subject_id)
group by name_subject
order by Среднее desc

#3.1-3
/*
select name_student, result
from
    attempt inner join student using(student_id)
where result >= all(
                    select result from attempt
                    )
order by 1;
*/
select name_student, result
from
    attempt inner join student using(student_id)
where result = (select max(result) from attempt)
order by 1;

#3.1-4
-- select name_student, name_subject, datediff(max(date_attempt),min(date_attempt)) as Интервал
-- from attempt
--     inner join student using(student_id)
--     inner join subject using(subject_id)
-- group by name_student, name_subject
-- having count(attempt_id) > 1
-- order by Интервал
select name_student, name_subject, datediff(max(date_attempt),min(date_attempt)) as Интервал
from attempt
    inner join student using(student_id)
    inner join subject using(subject_id)
group by name_student, name_subject
having count(attempt_id) > 1
order by Интервал;

#3.1-5
select name_subject, count(distinct student_id) as Количество
from
    attempt right join subject using(subject_id)
group by name_subject
order by name_subject;

#3.1-6
select question_id, name_question
from
    question inner join subject using(subject_id)
where name_subject = "Основы баз данных"
order by rand()
limit 3;

#3.1-7
select name_question, name_answer, if(is_correct, "Верно", "Неверно") as Результат
from testing
    inner join question using(question_id)
    inner join answer using(answer_id)
where attempt_id = 7;


#3.1-8
select name_student, name_subject, date_attempt, round(sum(is_correct) / 3 * 100,2) as Результат
from
    attempt
    inner join testing using(attempt_id)
    inner join answer on testing.answer_id = answer.answer_id
    inner join student using(student_id)
    inner join subject using(subject_id)
group by name_student, name_subject, date_attempt
order by name_student asc, date_attempt desc;


#3.1-9
select name_subject, CONCAT(SUBSTRING(name_question, 1, 30), '...') as Вопрос,
count(attempt_id) as Всего_ответов, round(sum(is_correct)/count(attempt_id) * 100,2) as Успешность
from question
    inner join subject using(subject_id)
    inner join answer using(question_id)
    inner join testing using(answer_id)
group by name_subject, name_question
order by name_subject asc, Успешность desc, Вопрос asc;


#3.2-1
insert into attempt(student_id, subject_id, date_attempt)
select q1.student_id, q2.subject_id, now()
from (select student_id
        from student
        where name_student = "Баранов Павел") q1,
    (select subject_id
        from subject
        where name_subject = "Основы баз данных") q2

#3.2-2
insert into testing(attempt_id, question_id)
select attempt_id, question_id
from attempt inner join question using(subject_id)
where attempt_id = (select max(attempt_id) from attempt)
order by rand()
limit 3;

select * from testing;

#3.2-3
update attempt
set result = (select round(sum(is_correct) / 3 * 100,1)
from testing inner join answer using(answer_id)
where attempt_id = 8
group by attempt_id)
where attempt_id = 8;


#3.2-4
delete from attempt
where date_attempt < date('2020-05-01');

---

#3.3-2
select name_enrollee
from enrollee
inner join program_enrollee using(enrollee_id)
inner join program using(program_id)
where name_program = 'Мехатроника и робототехника'
order by name_enrollee;

#3.3-3
select name_program
from subject
inner join program_subject using(subject_id)
inner join program using(program_id)
where name_subject = 'Информатика'
order by name_program desc;

#3.3-4
select name_subject,
count(enrollee_id) as Количество,
max(result) as Максимум,
min(result) as Минимум,
round(avg(result),1) as Среднее
from subject inner join enrollee_subject using(subject_id)
group by name_subject
order by name_subject;

#3.3-5
select name_program
from program inner join program_subject using(program_id)
group by name_program
having min(min_result) >= 40
order by name_program;

---
select p.name_program
from program p
where 40 <= all(
    select ps.min_ball 
    from program_subject ps 
    where ps.program_id = p.program_id)
order by p.name_program
---

#3.3-6
select name_program, plan
from program
where plan = (select max(plan) from program);

#3.3-7
select name_enrollee, if(ISNULL(sum(bonus)), 0, sum(bonus)) as Бонус
from enrollee
left join enrollee_achievement using(enrollee_id)
left join achievement using(achievement_id)
group by name_enrollee
order by name_enrollee;

---
select name_enrollee, sum(coalesce(add_ball, 0)) as Бонус
from enrollee e
left join enrollee_achievement ea on e.enrollee_id=ea.enrollee_id
left join achievement a on a.achievement_id=ea.achievement_id
group by name_enrollee
order by 1;
---

#3.3-8
select name_department,
name_program,
plan,
count(enrollee_id) as Количество,
round(count(enrollee_id)/plan, 2) as Конкурс
from program
join program_enrollee using(program_id)
join department using(department_id)
group by name_department, name_program, plan
order by Конкурс desc;

#3.3-9
select name_program
from program
join program_subject using(program_id)
join subject using(subject_id)
where name_subject in("Информатика", "Математика")
group by name_program
having count(name_subject) >= 2
order by name_program;

-
select name_program
from subject inner join program_subject using (subject_id)
             inner join program using (program_id)
group by name_program 
having sum(name_subject = 'Информатика' or name_subject = 'Математика') = 2
order by name_program;
-

#3.3-10
select name_program, name_enrollee, sum(result) as itog
from enrollee
join program_enrollee using(enrollee_id)
join program using(program_id)
join program_subject using(program_id)
join enrollee_subject on program_subject.subject_id = enrollee_subject.subject_id
and enrollee.enrollee_id = enrollee_subject.enrollee_id
group by name_program, name_enrollee
order by name_program, itog desc;


#3.3-11
select name_program, name_enrollee
from program
join program_enrollee using(program_id)
join enrollee using(enrollee_id)
join program_subject using(program_id)
join enrollee_subject on program_subject.subject_id = enrollee_subject.subject_id
and enrollee.enrollee_id = enrollee_subject.enrollee_id
where result < min_result
order by name_program, name_enrollee;


#3.4-1
CREATE TABLE applicant
as
select program_id, enrollee.enrollee_id as enrollee_id, sum(result) as itog
from enrollee
join program_enrollee using(enrollee_id)
join program using(program_id)
join program_subject using(program_id)
join enrollee_subject on program_subject.subject_id = enrollee_subject.subject_id
and enrollee.enrollee_id = enrollee_subject.enrollee_id
group by program_id, enrollee_id
order by program_id, itog desc;

select * from applicant;


#3.4-2
delete from applicant
where (program_id, enrollee_id) in (select program.program_id as program_id, enrollee.enrollee_id as enrollee_id
from program
join program_enrollee using(program_id)
join enrollee using(enrollee_id)
join program_subject using(program_id)
join enrollee_subject on program_subject.subject_id = enrollee_subject.subject_id
and enrollee.enrollee_id = enrollee_subject.enrollee_id
where result < min_result
order by program_id, enrollee_id);

select * from applicant;

-
DELETE applicant
FROM applicant
JOIN program_subject USING(program_id)
JOIN enrollee_subject USING(enrollee_id, subject_id)
WHERE result < min_result;

SELECT * FROM applicant;
-

#3.4-3
update applicant
set itog = itog + (select bonus_s from
    (
    select enrollee_id, program_id, if(ISNULL(sum(bonus)), 0, sum(bonus)) as bonus_s
    from applicant
    left join enrollee_achievement using(enrollee_id)
    left join achievement using(achievement_id)
    group by enrollee_id, program_id
    ) b
    where applicant.enrollee_id = b.enrollee_id and
    applicant.program_id = b.program_id
);

select * from applicant;


#3.4-4
create table applicant_order
as
select * from applicant
order by program_id, itog desc;

select * from applicant_order;

drop table applicant;


#3.4-5
alter table applicant_order add str_id int first;
select * from applicant_order;


#3.4-6
SET @num_pr := 0;
SET @row_num := 1;

update applicant_order
    set str_id = (
                    select str_id from
                    (
                        select
                        program_id,
                        enrollee_id,
                        if(program_id = @num_pr, @row_num := @row_num + 1, (@num_pr := program_id) and (@row_num := 1)) AS str_id
                        from applicant_order
                    ) a
                where (applicant_order.enrollee_id, applicant_order.program_id) = (a.enrollee_id, a.program_id)
                );

select * from applicant_order;


#3.4-7
create table student as
select name_program, name_enrollee, itog
from program
join applicant_order using(program_id)
join enrollee using(enrollee_id)
where str_id <= plan
order by name_program, itog desc;

select * from student;


#3.5-1
select CONCAT(SUBSTRING(concat(l.module_id, " ", m.module_name), 1, 16), '...') as Модуль,
CONCAT(SUBSTRING(concat(l.module_id, ".", l.lesson_position, " ", l.lesson_name), 1, 16), '...') as Урок,
concat(l.module_id, ".", l.lesson_position, ".", s.step_position, " ", s.step_name) as Шаг
from lesson as l
join module as m using(module_id)
join step as s using(lesson_id)
where step_name like "%ложенн% запрос%"
order by l.module_id, l.lesson_position, s.step_position;


#3.5-2
insert into step_keyword
select step_id, keyword_id
from keyword cross join step
where regexp_instr(concat(step_name, ' '), concat(' ', keyword_name,'[^[:alpha:]]')) > 0;

select * from step_keyword;

--
insert into step_keyword
select step_id, keyword_id
from keyword cross join step
where regexp_instr(step_name, concat(' ', keyword_name,'[^[:alpha:]]')) > 0
or regexp_instr(step_name, concat(' ', keyword_name,'$')) > 0;

select * from step_keyword;
--


#3.5-3
select concat(module_id, ".", lesson_position, ".", if(step_position < 10, concat("0", step_position), step_position), " ", step_name) as Шаг
from keyword
join step_keyword using(keyword_id)
join step using(step_id)
join lesson using(lesson_id)
join module using(module_id)
where keyword_name in ('MAX', 'AVG')
group by step_id
having count(keyword_id) >= 2
order by Шаг;


#3.5-4
select Группа,
    CASE
        WHEN Группа = "I" THEN "от 0 до 10"
        WHEN Группа = "II" THEN "от 11 до 15"
        WHEN Группа = "III" THEN "от 16 до 27"
        ELSE "больше 27"
    END as Интервал,
    count(rate) as Количество
from
(
    SELECT student_name, rate, 
        CASE
            WHEN rate <= 10 THEN "I"
            WHEN rate <= 15 THEN "II"
            WHEN rate <= 27 THEN "III"
            ELSE "IV"
        END AS Группа
    FROM      
        (
         SELECT student_name, count(*) as rate
         FROM 
             (
              SELECT student_name, step_id
              FROM 
                  student 
                  INNER JOIN step_student USING(student_id)
              WHERE result = "correct"
              GROUP BY student_name, step_id
             ) query_in
         GROUP BY student_name 
         ORDER BY 2
        ) query_in_1
) a
group by Группа;

--
select Группа,
    CASE
        WHEN Группа = "I" THEN "от 0 до 10"
        WHEN Группа = "II" THEN "от 11 до 15"
        WHEN Группа = "III" THEN "от 16 до 27"
        ELSE "больше 27"
    END as Интервал,
    count(rate) as Количество
from
(
    SELECT student_name, rate, 
        CASE
            WHEN rate <= 10 THEN "I"
            WHEN rate <= 15 THEN "II"
            WHEN rate <= 27 THEN "III"
            ELSE "IV"
        END AS Группа
    FROM      
        (
         SELECT student_name, count(distinct step_id) as rate
         FROM 
             student 
             INNER JOIN step_student USING(student_id)
            WHERE result = "correct"
            GROUP BY student_name
            ) query_in
) a
group by Группа
order by 1;
--


#3.5-5
WITH get_count_correct (st_n_c, count_correct) 
  AS (
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "correct"
    GROUP BY step_name
   ),
  get_count_wrong (st_n_w, count_wrong) 
  AS (
    SELECT step_name, count(*)
    FROM 
        step 
        INNER JOIN step_student USING (step_id)
    WHERE result = "wrong"
    GROUP BY step_name
   )  
SELECT st_n_c AS Шаг,
    CASE
    WHEN count_wrong IS NULL THEN 100
    WHEN count_correct IS NULL THEN 0
    ELSE ROUND(count_correct / (count_correct + count_wrong) * 100) 
    END AS Успешность
FROM  
    get_count_correct 
    LEFT JOIN get_count_wrong ON st_n_c = st_n_w
UNION
SELECT st_n_w AS Шаг,
    CASE
    WHEN count_wrong IS NULL THEN 100
    WHEN count_correct IS NULL THEN 0
    ELSE ROUND(count_correct / (count_correct + count_wrong) * 100) 
    END AS Успешность
FROM  
    get_count_correct 
    RIGHT JOIN get_count_wrong ON st_n_c = st_n_w
ORDER BY 2, 1;


#3.5-6
SET @max_progress = (SELECT COUNT(DISTINCT step_id) FROM step_student);

with get_progress (student_name, progress) 
  as (
    select student_name,
    ROUND((count(distinct step_id) / @max_progress) * 100) as progress
    from student join step_student using(student_id)
    where result = 'correct'
    group by student_name
    )
select student_name as Студент,
progress as Прогресс,
case
    when progress = 100 then "Сертификат с отличием"
    when progress >= 80 then "Сертификат"
    else ""
end as Результат
from get_progress
order by 2 desc, 1 asc;


#3.5-7
select student_name as Студент,
    concat(substring(step_name, 1, 20), "...") as Шаг,
    result as Результат,
    FROM_UNIXTIME(submission_time) as Дата_отправки,
    SEC_TO_TIME(submission_time - lag(submission_time, 1, submission_time)
               OVER (ORDER BY submission_time))
               as Разница
from step_student
join student using(student_id)
join step using(step_id)
where student_name = "student_61"
order by 4;


#3.5-8
with get_avg_time (lesson_id, avg_time)
as
(
    select lesson_id,
        round(avg(lesson_time / (60 * 60) ), 2) as avg_time
    from
    (
        select student_id,
            lesson_id,
            sum(submission_time - attempt_time) as lesson_time
        from step_student
        join step s using(step_id)
        where submission_time - attempt_time < 4 * 60 * 60 
        group by student_id, lesson_id
    ) a
    group by lesson_id
)
select
    rank() over (order by avg_time) as Номер,
    concat(m.module_id, ".", l.lesson_position, " ", l.lesson_name) as Урок,
    avg_time as Среднее_время
from module m
join lesson l using(module_id)
join get_avg_time using(lesson_id)
order by 3;


#3.5-9
