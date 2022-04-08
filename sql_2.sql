#2.1-3
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id),
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) 
);


#2.1-4
CREATE TABLE book (
    book_id INT PRIMARY KEY AUTO_INCREMENT, 
    title VARCHAR(50), 
    author_id INT NOT NULL, 
    genre_id INT,
    price DECIMAL(8,2), 
    amount INT, 
    FOREIGN KEY (author_id)  REFERENCES author (author_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)  REFERENCES genre (genre_id) ON DELETE SET NULL
);

--

#2.2-2
select name_genre
from
    genre left join book
    using(genre_id)
where book.genre_id is null;


#2.2-3
select name_city, name_author, DATE_ADD('2020-01-01', INTERVAL FLOOR(RAND() * 365) DAY) AS Дата
from city cross join author
order by name_city asc, Дата desc;


#2.2-7
SELECT title, name_author, name_genre, price, amount
FROM author
INNER JOIN book using(author_id)
INNER JOIN genre using(genre_id)
WHERE book.genre_id IN 
    (SELECT genre_id
     FROM book
     GROUP BY genre_id
     HAVING SUM(amount) >= ALL(SELECT SUM(amount) FROM book GROUP BY genre_id)
     )
ORDER BY title;


#2.2-8
select b.title as Название, name_author as Автор, b.amount + s.amount as Количество
from book b inner join author a using(author_id)
     inner join supply s on a.name_author = s.author
                            and s.title = b.title
                            and s.price = b.price


--

#2.3-1
UPDATE book b
     INNER JOIN author a using(author_id)
     INNER JOIN supply s ON b.title = s.title 
                         and s.author = a.name_author
SET b.price = (b.price * b.amount + s.price * s.amount) / (b.amount + s.amount),
    b.amount = b.amount + s.amount,
    s.amount = 0   
WHERE b.price != s.price;


#2.3-2
insert into author(name_author)
SELECT supply.author
FROM author 
    RIGHT JOIN supply on author.name_author = supply.author
WHERE name_author IS Null;

select * from author;


#2.3-3
insert into book(title, author_id, price, amount)
SELECT title, author_id, price, amount
FROM 
    author 
    INNER JOIN supply ON author.name_author = supply.author
WHERE amount <> 0;

select * from book;


#2.3-4
update book
set genre_id = 
    (
        select genre_id
        from genre
        where name_genre = 'Поэзия'
     )
where (title,author_id) = ('Стихотворения и поэмы',
                           (select author_id from author where name_author = 'Лермонтов М.Ю.'));

update book
set genre_id = 
    (
        select genre_id
        from genre
        where name_genre = 'Приключения'
     )
where (title,author_id) = ('Остров сокровищ',
                           (select author_id from author where name_author = 'Стивенсон Р.Л.'));


#2.3-5
DELETE FROM author
where author_id in (
                    select author_id
                    from book 
                    group by author_id
                    having sum(amount) < 20
                    );


#2.3-6
DELETE FROM genre
WHERE genre_id in (
    select genre_id
    from book
    group by genre_id
    having count(title) < 4
    );


#2.3-7
DELETE FROM author
USING 
    author
    INNER JOIN book b using(author_id)
    inner join genre g using(genre_id) 
WHERE g.name_genre = 'Поэзия';


--

#2.4-5
select buy.buy_id, b.title, b.price, b_b.amount
from
      buy inner join buy_book b_b using(buy_id)
          inner join book b using(book_id)
where buy.client_id = (
                    select client_id
                    from client
                    where name_client = "Баранов Павел"
                  )
order by buy_id, title;

#2.4-6
select name_author, title, count(b_b.book_id) as Количество
from
      book inner join author using(author_id)
      left join buy_book b_b using(book_id)
group by title, name_author

order by name_author, title;

#2.4-7
select name_city, count(buy_id) as Количество
from
    city inner join client using(city_id)
    inner join buy using(client_id)
group by name_city

order by Количество desc, name_city

#2.4-8
select buy_id, date_step_beg
from buy_step
where date_step_beg is not null
      and step_id = (
                  select step_id
                  from step
                  where name_step = 'Оплата'
                );

#2.4-9
select buy.buy_id, c.name_client, sum(b.price * b_b.amount) as Стоимость
from buy
    inner join buy_book b_b using(buy_id)
    inner join book b using(book_id)
    inner join client c using(client_id)
group by buy.buy_id, c.name_client
order by buy.buy_id;

#2.4-10
select buy_id, name_step
from
    buy_step inner join step using(step_id)
where (date_step_beg is not null) and (date_step_end is null)
order by 1;

#2.4-11
select buy_id, datediff(date_step_end, date_step_beg) as Количество_дней,
      if(datediff(date_step_end, date_step_beg) > days_delivery, datediff(date_step_end, date_step_beg) - days_delivery, 0) as Опоздание

from buy
    inner join client using(client_id)
    inner join city using(city_id)
    inner join buy_step using(buy_id)
    inner join step using(step_id)

where name_step = 'Транспортировка' and date_step_end is not null
order by 1

#2.4-12
select distinct c.name_client
from
    buy
    inner join client c using(client_id)
    inner join buy_book b_b using(buy_id)
    inner join book b using(book_id)
    inner join author a using(author_id)
where a.name_author = "Достоевский Ф.М."
order by 1

#2.4-13
/*
select name_genre, sum(b_b.amount) as Количество
from
    genre
    inner join book b using(genre_id)
    inner join buy_book b_b using(book_id)
group by name_genre, genre_id
having sum(b_b.amount) = (
                      select sum(buy_book.amount)
                      from buy_book
                            inner join book using(book_id)
                      group by genre_id
                      order by 1 desc
                      limit 1
                      );
*/

select name_genre, sum(b_b.amount) as Количество
from
    genre
    inner join book b using(genre_id)
    inner join buy_book b_b using(book_id)
group by name_genre, genre_id
having sum(b_b.amount) >= all(
                            select sum(buy_book.amount)
                            from buy_book
                            inner join book using(book_id)
                            group by genre_id
                            );

#2.4-14
select year(date_payment) as Год, monthname(date_payment) as Месяц, sum(price * amount) as Сумма
from
    buy_archive
group by Год, Месяц
    UNION
select year(date_step_end) as Год, monthname(date_step_end) as Месяц, sum(book.price * buy_book.amount) as Сумма
from
    book 
    INNER JOIN buy_book USING(book_id)
    INNER JOIN buy USING(buy_id) 
    INNER JOIN buy_step USING(buy_id)
    INNER JOIN step USING(step_id)
WHERE  date_step_end IS NOT Null and name_step = "Оплата"
group by Год, Месяц
order by Месяц, Год

#2.4-15
SELECT title, sum(q.Количество) as Количество, sum(q.Сумма) as Сумма
from
    (select title, sum(buy_archive.amount) as Количество, sum(buy_archive.price * buy_archive.amount) as Сумма
    from
        buy_archive inner join book using(book_id)
    group by title
        UNION ALL
    select title, sum(buy_book.amount) as Количество, sum(price * buy_book.amount) as Сумма
    from
        book 
        INNER JOIN buy_book USING(book_id)
        INNER JOIN buy USING(buy_id) 
        INNER JOIN buy_step USING(buy_id)
        INNER JOIN step USING(step_id)
    WHERE  date_step_end IS NOT Null and name_step = "Оплата"
    group by title) q
group by title
order by 3 desc;

---

#2.5-2
INSERT INTO client(name_client, city_id, email)
SELECT 'Попов Илья', city_id, 'popov@test'
FROM city
WHERE name_city = "Москва";

#2.5-3
insert into buy(buy_description, client_id)
select "Связаться со мной по вопросу доставки", client_id
from client
where name_client = "Попов Илья";

#2.5-4
insert into buy_book (buy_id, book_id, amount)
select 5, book_id, 2
from book where title = 'Лирика';

insert into buy_book (buy_id, book_id, amount)
select 5, book_id, 1
from book where title = 'Белая гвардия';

#2.5-5
update book
inner join buy_book b_b using(book_id)
set book.amount = book.amount - b_b.amount
where buy_id = 5

#2.5-6
CREATE TABLE buy_pay AS
select title, name_author, price, b_b.amount, (book.price * b_b.amount) as Стоимость
FROM
    book
    inner join author a using(author_id)
    inner join buy_book b_b using(book_id)
where buy_id = 5
order by title;

select * from buy_pay;

#2.5-7
CREATE TABLE buy_pay AS
select buy_id, sum(b_b.amount) as Количество, sum(book.price * b_b.amount) as Итого
FROM
    book
    inner join buy_book b_b using(book_id)
where buy_id = 5
order by title;

select * from buy_pay;

#2.5-8
insert into buy_step(buy_id, step_id)
select 5, step_id
from step

#2.5-9
update buy_step
set date_step_beg = DATE('2020-04-12')
where buy_id = 5 and step_id = (
                                select step_id
                                from step
                                where name_step = 'Оплата'
                                );

#2.5-10
update buy_step
set date_step_end = DATE('2020-04-13')
where buy_id = 5 and step_id = (
                                select step_id
                                from step
                                where name_step = 'Оплата'
                                );

update buy_step
set date_step_beg = DATE('2020-04-13')
where buy_id = 5 and step_id = 1 + (
                                    select step_id
                                    from step
                                    where name_step = 'Оплата'
                                    );


