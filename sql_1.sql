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
