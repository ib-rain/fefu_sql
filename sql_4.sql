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


###
#4 SQL window function examples
#https://www.youtube.com/watch?v=XBE09l-UYTE

-- https://platform.stratascratch.com/coding/10302-distance-per-dollar?code_type=3
select request_date,
    DATE_FORMAT(request_date, '%Y-%m'),
    round(abs(distance_to_travel / monetary_cost - avg(distance_to_travel / monetary_cost) over (partition by DATE_FORMAT(request_date, '%Y-%m'))), 2) as abs_av_diff
from uber_request_logs
order by request_date;


-- https://platform.stratascratch.com/coding/9898-unique-salaries?utm_source=youtube&utm_medium=click&utm_campaign=YT+description+link&code_type=1
select department,
    salary,
    salary_rank
from
(
    select department,
        salary,
        rank() over (partition by department order by salary desc) as salary_rank
    from
    (
        select department, salary
        from twitter_employee
        group by department, salary
        order by department, salary
    ) a
) b
where salary_rank <= 3
order by 1, 2 desc;


-- https://platform.stratascratch.com/coding/10303-top-percentile-fraud?code_type=1
select policy_num,
    state,
    claim_cost,
    fraud_score
from
(
    select *,
        ntile(100) over (partition by state order by fraud_score desc) as percentile
    from fraud_score
) q
where percentile <= 5;


-- https://platform.stratascratch.com/coding/9637-growth-of-airbnb?code_type=3
select y,
    hosts_count as cur_hosts,
    prev_hosts_count as prev_hosts,
    100 * round((hosts_count - prev_hosts_count) / prev_hosts_count, 2) as rate_of_growth
from
(
    select y,
        hosts_count,
        lag(hosts_count, 1) over (order by y) as prev_hosts_count
    from
    (
        select DATE_FORMAT(host_since, '%Y') as y,
            count(id) as hosts_count
        from airbnb_search_details
        group by DATE_FORMAT(host_since, '%Y')
    ) q1
) q2
order by 1;

###
#https://www.youtube.com/watch?v=W_IERUwElkg&ab_channel=StrataScratch
#SQL CASE WHEN
-- https://platform.stratascratch.com/coding/9632-host-popularity-rental-prices?code_type=3
select popularity_rating,
    min(price) as min_price,
    avg(price) as avg_price,
    max(price) as max_price
from
(
    select concat(price, " ", room_type, " ", host_since, " ", zipcode) as host_id,
        number_of_reviews,
        price,
        case
            when number_of_reviews = 0 then "New"
            when number_of_reviews <= 5 then "Rising"
            when number_of_reviews <= 15 then "Trending Up"
            when number_of_reviews <= 40 then "Popular"
            else "Hot"
        end as popularity_rating
    from airbnb_host_searches
    group by host_id, number_of_reviews, price
) q1
group by popularity_rating


-- https://platform.stratascratch.com/coding/9738-business-inspection-scores?code_type=3
select type,
    avg(inspection_score) as avg_insp_score
from
(
    select inspection_score,
        case
            when business_name like '%Restaurant%' then 'Restaurant'
            when business_name like '%Cafe%' then 'Cafe'
            when business_name like '%Taqueria%' then 'Taqueria'
            when business_name like '%Kitchen%' then 'Kitchen'
            when business_name like '%Garden%' then 'Garden'
            when business_name like '%School%' then 'School'
            else 'Other'
        end as type
    from sf_restaurant_health_violations
) q1
group by type

-- https://platform.stratascratch.com/coding/10289-top-engagements?code_type=3
# DIRTY CASE-WHEN ONE-LINER 
select
    100 * round(count(case when (clicked = 1)
        and (search_results_position <= 3)
        then e.search_id else null end) / count(*), 4) as percentage
from fb_search_events e
join fb_search_results r using(search_id);


###

#4.3-4
