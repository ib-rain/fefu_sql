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

