#4.1-1
select beg_range,
    end_range,
    round(avg(price), 2) as Средняя_цена,
	sum(price * amount) as Стоимость,
	count(price) as Количество
from
(
	select beg_range,
		end_range,
		price,
		amount
	from book
    join stat on (price >= beg_range) and (price <= end_range)
) q1
group by beg_range, end_range
order by 1, 2;


#4.1-2
delete from book
	where price % 1 = 0.99;
select * from book;

delete from supply
	where price % 1 = 0.99;
select * from supply;


#4.1-3
select author,
	title,
	price,
	amount,
	if(price > 600, round(price * 0.2, 2), '-') as sale_20,
	if(price > 600, round(price * 0.8, 2), '-') as price_sale
from book
order by 1, 2;


#4.1-4
set @avg_price = (select avg(price) from book);

select author,
	@avg_price,
	sum(price * amount) as Стоимость
from book
group by author
order by 2 desc;


#4.1-5
set @avg_price = (select avg(price) from book);

select author,
	sum(price * amount) as Стоимость
from book
group by author
having max(price) > @avg_price
order by 2 desc;


#4.1-6
select author as Автор,
	title as Название_книги,
	amount as Количество,
	price as Розничная_цена,
	if(amount >=10, 15, 0) as Скидка,
	round(price * (1 - if(amount >=10, 0.15, 0)), 2) as Оптовая_цена
from book
order by 1, 2;


#4.1-7
select author,
	count(title) as Количество_произведений,
	min(price) as Минимальная_цена,
	sum(amount) as Число_книг
from book
where author in (
	select author
	from book
	where (price > 500)
		and (amount > 1)
)
group by author
having count(title) >=2
order by 1;


#4.2-1
select "Донцова Дарья" as author,
	concat("Евлампия Романова и ", title) as title,
	round(price * 1.42, 2) as price
from book
order by price desc;


#4.2-2
with get_order_amounts
as
(
	select name_genre,
		sum(b_b.amount) as order_amount
	from genre
	join book b using(genre_id)
	join buy_book b_b using(book_id)
	group by name_genre
)
select name_genre,
	order_amount as Количество
from get_order_amounts
where order_amount = (
	select min(order_amount)
	from get_order_amounts
	where order_amount >= 1
);


#4.2-3	
set @avg_amount = (
    select avg(amount) as avg_amount
    from
    (
        select amount from book
        union all
        select amount from supply
    ) q1
);

create table store as
	select title,
		author,
		max_price as price,
		sum_amount as amount
	from 
	(
		select title,
			author,
			max(price) as max_price,
			sum(amount) as sum_amount
		from 
	    (
	        select title, author, price, amount from book
	        union all
	        select title, author, price, amount from supply
	    ) q2
	    group by title, author
	) q3
	where sum_amount > @avg_amount
	order by 2, 3 desc;

select * from store;


#4.2-4
select author,
	title,
	if(price <500, 'низкая', if(price < 700, 'средняя', 'высокая')) as price_category,
	price * amount as cost
from book
where author not like '%Есенин%' and
	title not like '%Белая гвардия%'
order by 4 desc, 2 asc;


#4.2-5
set @max_cost = (select max(price * amount) from book);

select title,
	author,
	amount,
	round(@max_cost - price * amount, 2) as Разница_с_макс_стоимостью
from book
where amount % 2 = 1
order by 4 desc;


#4.2-6
select title as Наименование,
	price as Цена,
	if(amount <= 5, 500, 'Бесплатно') as Стоимость_доставки
from book
where price > 600
order by 2 desc;


#4.2-7
select author,
	title,
	amount,
	price,
	if(amount >= 5, '50%', if(price >= 700, '20%', '10%')) as Скидка,
	round(if(amount >= 5, 0.5, if(price >= 700, 0.8, 0.9)) * price, 2) Цена_со_скидкой
from book
order by 1;


#4.2-8
select author,
	title,
	amount,
	price as real_price,
	round(if(amount * price > 5000, 1.2, 0.8) * price, 2) as new_price,
	if(price <= 500, 99.99, if(amount < 5, 149.99, 0)) as delivery_price
from book
where (author like '%Есенин%'
    or author like '%Булгаков%')
	and (amount between 3 and 14)
order by 1 asc, 2 desc, 6 asc;


#4.3-1
select author,
	title,
	price div 1 as Рубли,
	round(100 * (price % 1), 0) as Копейки
from book
order by 4 desc;


#4.3-2
select concat('Графоман и ', author) as Автор,
	concat(title, '. Краткое содержание.') as Название,
	if(0.4 * price < 250, 0.4 * price, 250) as Цена,
	if(amount <= 3, 'высокий', if(amount <= 10, 'средний', 'низкий')) as Спрос,
	if(amount <= 2, 'очень мало', if(amount <= 14, 'в наличии', 'много')) as Наличие
from book
order by 3, amount, title;


#4.3-3
with get_joined as
(
	select name_client,
		sum(book.price * b_b.amount) as total_sum,
		count(distinct b.buy_id) as total_count,
		sum(b_b.amount) as book_amount
	from client c
	join buy b using(client_id)
	join buy_book b_b using(buy_id)
	join book using(book_id)
	group by name_client
)

select name_client,
	total_sum as Общая_сумма_заказов,
	total_count as Заказов_всего,
	book_amount as Книг_всего
from get_joined
where total_sum > (
	select avg(total_sum) from get_joined
)
order by 1;


#4.3-4
set @sum_income = (select sum(price * amount) from book);

select author,
    title,
    price,
    amount,
    round(100 * (price * amount) / @sum_income, 2) as income_percent
from book
order by 5 desc;


#4.3-5
select name_author,
	name_genre
	count(book_id) as Количество
from author
join book using(author_id)
join genre using(genre_id)
group by name_author, name_genre
order by 1, 3 desc, 2;


#4.3-6
with get_author_genres
as
(
    select name_author,
        name_genre,
        author_id,
        genre_id
    from genre
    cross join author
)

select name_author,
    name_genre,
    count(book_id) as Количество
from get_author_genres
left join book using(author_id, genre_id)
group by name_author, name_genre
order by 1, 3 desc, 2;


#4.3-7
select author as Автор,
	title as Название_книги,
	price as Цена,
	case
		when price <= 600 then 'ручка'
		when price <= 700 then 'детская раскраска'
		else 'гороскоп'
	end as Подарок
from book
where price >= 500
order by 1, 2;


#4.3-8
select author as Автор,
    min(amount) as Наименьшее_кол_во,
    max(amount) as Наибольшее_кол_во
from book
group by author
having sum(amount) < 10;


#4.3-9
select buy_book_id,
    buy_id,
    book_id,
    amount
from buy_book
order by 1, 2, 3, 4;

set @baranov_dostoevsky_buy_id = (
	select buy_id
	from buy_book
    join buy using(buy_id)
    join client using(client_id)
    join book using(book_id)
    join author using(author_id)
	where name_client like 'Баранов Павел'
        and name_author like '%Достоевский%'
);

insert into buy_book(buy_id, book_id, amount)
select @baranov_dostoevsky_buy_id as buy_id,
	book_id,
	1 as amount
from book
join author using(author_id)
where name_author like '%Достоевский%';

select buy_book_id,
    buy_id,
    book_id,
    amount
from buy_book
order by 1, 2, 3, 4;

