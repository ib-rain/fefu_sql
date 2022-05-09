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
