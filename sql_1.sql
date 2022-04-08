#1.1-1
create table book(
    book_id INT PRIMARY KEY AUTO_INCREMENT,
    title varchar(50),
    author varchar(30),
    price decimal(8,2),
    amount int
    );


#1.1-2
INSERT INTO book (title, author, price, amount) 
VALUES ('Мастер и Маргарита', 'Булгаков М.А.', 670.99, 3);


#1.1-3
INSERT INTO book (title, author, price, amount) 
VALUES ('Белая гвардия', 'Булгаков М.А.', 540.50, 5);

INSERT INTO book (title, author, price, amount) 
VALUES ('Идиот', 'Достоевский Ф.М.', 460.00, 10);

INSERT INTO book (title, author, price, amount) 
VALUES ('Братья Карамазовы', 'Достоевский Ф.М.', 799.01, 2);

Select * from book;

--

#1.4-1
select author, title, price 
from book
where price <= (
                select avg(price)
                from book
                )
order by price desc;


#1.4-2
select author, title, amount
from book
where amount in (
                select amount from book
                group by amount
                having count(amount) = 1
                );


#1.4-4
select author, title, price
from book
where price < any (select min(price) from book group by author);


#1.4-5
SELECT title, author, amount, (SELECT max(amount) FROM book) - amount as Заказ
from book
WHERE (SELECT max(amount) FROM book) - amount > 0;


--

#1.5-9
CREATE TABLE ordering AS
SELECT author, title, 
   (
    SELECT ROUND(AVG(amount)) 
    FROM book
   ) AS amount
FROM book
WHERE amount < (
                SELECT AVG(amount)
                FROM book
               );

SELECT * FROM ordering;


--

#1.6-6
select name,city,date_first,date_last
from trip
where datediff(date_last,date_first) = (
                                        select min(datediff(date_last,date_first)) from trip
                                        );


#1.6-10
select name,sum(per_diem*(datediff(date_last,date_first)+1)) as Сумма
from trip
where name in (select name from trip group by name having count(city)>3)
group by name
order by Сумма desc


--

#1.7-6
update fine f, payment p
set f.date_payment = p.date_payment,
f.sum_fine = if(datediff(f.date_payment, f.date_violation) <= 20, f.sum_fine / 2, f.sum_fine)
where f.date_payment is null
    and (f.name,f.number_plate,f.violation,f.date_violation) = (p.name,p.number_plate,p.violation,p.date_violation);

