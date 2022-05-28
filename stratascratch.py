#https://www.youtube.com/watch?v=XBE09l-UYTE
# https://platform.stratascratch.com/coding/10302-distance-per-dollar?code_type=2

# Import your libraries
import pandas as pd

# Start writing code
uber_request_logs.head()

dist_cost = uber_request_logs[['request_date', 'distance_to_travel', 'monetary_cost']]

dist_cost['dist_per_dollar'] = dist_cost.distance_to_travel / dist_cost.monetary_cost
dist_cost['request_year_month'] = dist_cost.request_date.dt.to_period("M")
dist_cost['avg_dist_per_dollar'] = (
    dist_cost.groupby('request_year_month')
    .dist_per_dollar
    .transform('mean')
)
dist_cost['avg_diff'] = (dist_cost.dist_per_dollar - dist_cost.avg_dist_per_dollar).abs().round(2)

dist_cost[['request_date', 'request_year_month', 'avg_diff']].sort_values('request_date')


###
# https://platform.stratascratch.com/coding/9898-unique-salaries?code_type=2

# Import your libraries
import pandas as pd

# Start writing code
twitter_employee.head()

salaries_per_department = (
    twitter_employee[['department', 'salary']]
    .sort_values(['department', 'salary'], ascending=[True, False])
    .drop_duplicates()
    .groupby('department').head(3)
)
salaries_per_department['salary_rank_in_department'] = salaries_per_department.groupby('department').rank(ascending=False)

salaries_per_department


###
# https://platform.stratascratch.com/coding/9637-growth-of-airbnb?code_type=2

# Import your libraries
import pandas as pd

# Start writing code
airbnb_search_details.head()

hosts_per_year = airbnb_search_details[['host_since', 'id']]
hosts_per_year['year'] = hosts_per_year.host_since.dt.year

hosts_per_year = (
    hosts_per_year.groupby('year', as_index=False)
    .id.count()
    .rename(columns={'id': 'cur_hosts'})
)

hosts_per_year['prev_hosts'] = hosts_per_year.cur_hosts.shift(1)
hosts_per_year['rate_of_growth'] = (100 * (hosts_per_year.cur_hosts - hosts_per_year.prev_hosts) / hosts_per_year.prev_hosts).round(0)
hosts_per_year


###
#https://www.youtube.com/watch?v=W_IERUwElkg&ab_channel=StrataScratch
# https://platform.stratascratch.com/coding/9632-host-popularity-rental-prices?code_type=2

# Import your libraries
import pandas as pd
import numpy as np

# Start writing code
airbnb_host_searches.head()

hosts_popularity_prices = airbnb_host_searches[['price', 'number_of_reviews']]

#Tip: The `id` column in the table refers to the search ID. You'll need to create your own host_id by concating price, room_type, host_since, zipcode, and number_of_reviews.
hosts_popularity_prices['host_id'] = (
    airbnb_host_searches.price.astype(str)
    + airbnb_host_searches.room_type
    + airbnb_host_searches.host_since.astype(str)
    + airbnb_host_searches.zipcode.astype(str)
    + airbnb_host_searches.number_of_reviews.astype(str)
)

hosts_popularity_prices['popularity_rating'] = np.select(
    [
        hosts_popularity_prices.number_of_reviews.eq(0),
        hosts_popularity_prices.number_of_reviews.between(1, 5, inclusive='both'),
        hosts_popularity_prices.number_of_reviews.between(6, 15, inclusive='both'),
        hosts_popularity_prices.number_of_reviews.between(16, 40, inclusive='both'),
        hosts_popularity_prices.number_of_reviews.gt(40)
        
    ],
    [
        'New',
        'Rising',
        'Trending Up',
        'Popular',
        'Hot'
    ],
    default='Unknown!!!'
)

hosts_popularity_prices = (
    hosts_popularity_prices
    .drop_duplicates()
    .groupby('popularity_rating', as_index=False)
    .agg({'price':['min', 'mean', 'max']})
)
hosts_popularity_prices

###
# https://platform.stratascratch.com/coding/9738-business-inspection-scores?code_type=2

# Import your libraries
import pandas as pd

# Start writing code
sf_restaurant_health_violations.head()

business_inspection = sf_restaurant_health_violations[['business_name', 'inspection_score']]

business_inspection['business_type'] = (
    business_inspection
    .business_name
    .apply(str.lower)
    .str.extract(r"""(Restaurant|Cafe|Taqueria|Kitchen|Garden|School)""".lower()).fillna('other')
)

business_inspection_score = (
    business_inspection
    .groupby('business_type', as_index=False)
    .agg({'inspection_score': ['mean', 'count']})
    .rename(columns={'inspection_scoremean': 'avg_inspection_score',
                     'inspection_scorecount': 'inspection_count'})
)
business_inspection_score


###
# https://platform.stratascratch.com/coding/10289-top-engagements?code_type=2

# Import your libraries
import pandas as pd

# Start writing code
fb_search_events.head()

fb_search = fb_search_events.merge(fb_search_results, how='inner', on='search_id')

(100 * fb_search.query('(clicked == 1) and (search_results_position <= 3)').count() / fb_search.count()).iloc[0].round(2)

