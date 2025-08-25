
-- GitHub Project: Website Traffic & Landing Page Analytics
-- Project Overview
-- This project demonstrates a comprehensive analysis of website traffic, campaign performance, and landing page optimization using SQL. It highlights how data-driven insights can guide marketing spend, improve conversion rates, and optimize user experience.
-- Key Objectives:
-- Analyze traffic sources and identify top-performing campaigns.
-- Calculate conversion rates by campaign, device type, and traffic segment.
-- Optimize bid strategy based on conversion performance.
-- Identify top pages and entry pages on the website.
-- Analyze bounce rates and A/B test landing pages.
-- Business Concepts Illustrated:
-- Traffic Source Analysis
-- Paid Campaign & UTM Tracking
-- Conversion Rate Analysis
-- Bid Optimization & Trend Analysis
-- Device-Level Performance Analysis
-- Top Website Content & Entry Page Analysis
-- Landing Page Performance & A/B Tes

-- Traffic Source Analysis

select w.utm_content,
count(distinct w.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
(count(distinct orders.order_id) / count(distinct w.website_session_id)) as
session_to_order_conv_rate
from website_sessions as w
	left join orders
    on orders.website_session_id= w.website_session_id
where w.website_session_id between 1000 and 2000
group by
w.utm_content
order by count(distinct w.website_session_id) desc
-- This analysis helps me compare the performance of marketing campaigns 
-- (via utm_content) in terms of how well they convert sessions into orders.

-- Assignment 1: Finding Top traffic Sources;
use mavenfuzzyfactory;
select 
utm_source,
utm_campaign,
http_referer,
Count(distinct website_session_id) as number_of_sessions
 from website_sessions
where created_at < '2012-04-12'
group by 
utm_source,
utm_campaign,
http_referer
order by number_of_sessions desc;

-- Conversion Rate Analysis

--  Finding Traffic conversion rate
use mavenfuzzyfactory;
select 
	Count(distinct website_sessions.website_session_id) as sessions,
	count(distinct orders.order_id) as orders,
	count(distinct orders.order_id) /count(distinct website_sessions.website_session_id) as session_to_order_conv_rate
	from website_sessions
	left join orders 
     on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at < '2012-04-14'
      and utm_source = 'gsearch'
      and utm_campaign = 'nonbrand';

-- Bid Optimazation and Trend Analysis 
select 
year(created_at),
week(created_at),
min(date(created_at)) AS week_start,
count(distinct website_session_id) as sessions

 from website_sessions
 
 where website_session_id between 100000 and 115000 -- arbitrary
 group by
 1,2;
 -- Pro Tip 'Pivoting' Data with Count and Case
 select 
 primary_product_id,
 Count(case when items_purchased=1 then order_id else null end) as count_single_item_orders,
 Count(case when items_purchased=2 then order_id else null end) as count_two_item_orders
 
 from orders
 
 where order_id between 31000 and 32000 -- arbitrary
 group by 1;
 -- Assignment: Can you please gsearch nonbrand trended session volume, 
 -- by week to see if the bid changes have caused volume to drop at all?
 
 select
 -- year(created_at) as year,
 -- week(created_at) as wk,
 min(date(created_at)) as week_start,
 count(distinct website_session_id) as session
 from website_sessions
 where utm_source= 'gsearch' and
 utm_campaign= 'nonbrand' and 
 created_at < '2012-05-12'
 group by 
 year(created_at),
 week(created_at);
 
 -- Device- Level- Conversion
-- Assignment: Could you pull conversion rates from session to order, by device type? ;

select website_sessions.device_type,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as orders,
(count(distinct orders.order_id)/ count(distinct website_sessions.website_session_id))  as conversion_rate
from website_sessions 
left join orders
on orders.website_session_id= website_sessions.website_session_id
where website_sessions.created_at < '2012-05-11'
      and utm_source = 'gsearch'
      and utm_campaign = 'nonbrand'
group by website_sessions.device_type;

-- Assignment . Could you pull weekly trends for both desktop and mobile
-- so we can see the impact on volume? You can use 2012-04-15 until the bid change as a baseline.

select 
-- yearweek(website_sessions.created_at) as year_week,
Count( distinct case when website_sessions.device_type= 'desktop' then website_sessions.website_session_id else null end) as count_desktop_session,
Count(distinct case when website_sessions.device_type = 'mobile' then website_sessions.website_session_id else null end) as count_mobile_session,
min(date(website_sessions.created_at)) as start_of_week
from website_sessions

where website_sessions.created_at < '2012-06-09' and
 website_sessions.created_at  > '2012-04-15' 
  and website_sessions.utm_source = 'gsearch'
      and website_sessions.utm_campaign = 'nonbrand'
group by yearweek(website_sessions.created_at)

-- Top Pages Analysis
-- Section 2 : Analyzing Top Website Pages
use mavenfuzzyfactory;
select 
pageview_url,
count( distinct website_pageview_id) as pgw
from
website_pageviews
where website_pageview_id < 1000 -- arbitrary
group by pageview_url
order by pgw desc;

create temporary table first_page_view
select 
website_session_id,
min(website_pageview_id) as min_pv_id
from
website_pageviews
where website_pageview_id < 1000 -- arbitrary
group by website_session_id;

select 
website_pageviews.pageview_url as landing_page, -- "entry page"
count(distinct first_page_view.website_session_id) as sessions_hitting_this_ladder
 from first_page_view
left join website_pageviews
on first_page_view.min_pv_id=website_pageviews.website_pageview_id
group by website_pageviews.pageview_url;
 
 
 -- Assignment: Could you help me get my head around the site by pulling the most-viewed website pages, 
 -- ranked by session volume?
 

 select 
 pageview_url,
 count(distinct website_session_id) as sessions
 
 from website_pageviews
 
 where created_at < "2012-06-09"
 group by pageview_url
 order by sessions desc;
 
 -- Assignment Would you be able to pull a list of the top entry pages?
 use mavenfuzzyfactory;
 create temporary table first_page_viewss
select 
website_session_id,
min(website_pageview_id) as min_pageview_id
from
website_pageviews
where created_at < "2012-06-12"
group by website_session_id;

select 
website_pageviews.pageview_url as landing_page,
count(first_page_viewss.website_session_id) as sessions_hitting_this_landing_page
from first_page_viewss
left join website_pageviews 
on website_pageviews.website_pageview_id=first_page_viewss.min_pageview_id
group by website_pageviews.pageview_url;

-- Landing Page bounce analysis

-- Analyzing Bounce Rates and landing page test
-- business context we want to see landing page performance for certain time period
-- Step 1: find the first website_pageview_id for relevant sessions
-- Step 2: identifying the landing page of each session
-- Step 3: counting pageviews for each session, to identify 'bounces'
-- Step 4: summarizing by counting sessions and bounced sessions 

-- Finding the minumum website pageview id associate with each session we care about
select
 website_pageviews.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview_id
 from website_pageviews
 inner join website_sessions
 on website_sessions.website_session_id= website_pageviews.website_session_id
 and website_sessions.created_at between '2014-01-01' and '2014-02-01'
 group by
 website_pageviews.website_session_id;
 -- same querry above but this time we are storing a dataset as a temporary table
 create temporary table first_pageviews_demo
 select
  website_pageviews.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview_id
 from website_pageviews
 inner join website_sessions
 on website_sessions.website_session_id= website_pageviews.website_session_id
 and website_sessions.created_at between '2014-01-01' and '2014-02-01'
 group by
 website_pageviews.website_session_id;
 
 select * from first_pageviews_demo;
 
 -- next we will brind the landing page to each session
 
 create temporary table sessions_w_landing_page_demo
 select 
 first_pageviews_demo.website_session_id,
 website_pageviews.pageview_url as landing_page
 from first_pageviews_demo
 left join website_pageviews
 on website_pageviews.website_pageview_id= first_pageviews_demo.min_pageview_id;-- website pageview is landing pageview
 
 select * from sessions_w_landing_page_demo;
 
 -- next we make a table to include a count of pageviews per session 
 -- first i will show you all of the sessions. then we will limit to bounced sessions and create a temporary table
 
 Create temporary table bounced_sessions_only
 select sessions_w_landing_page_demo.website_session_id,
 sessions_w_landing_page_demo.landing_page,
 count(website_pageviews.website_pageview_id) as count_of_page_views
 from sessions_w_landing_page_demo
 left join website_pageviews
 on website_pageviews.website_session_id= sessions_w_landing_page_demo.website_session_id
 group by
 sessions_w_landing_page_demo.website_session_id,
 sessions_w_landing_page_demo.landing_page
 having count(website_pageviews.website_pageview_id)= 1;
 
 select * from bounced_sessions_only;
 
 select 
 sessions_w_landing_page_demo.landing_page,
 sessions_w_landing_page_demo.website_session_id,
 bounced_sessions_only.website_session_id as bounced_website_session_id
 from sessions_w_landing_page_demo
	left join bounced_sessions_only
    on sessions_w_landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
    order by sessions_w_landing_page_demo.website_session_id;
    
-- final output 
	-- we will use the same querry we previously run and run a count of records
    -- we will group by landing page and then we will add a bounce rate column 

 select 
 sessions_w_landing_page_demo.landing_page,
 count(distinct sessions_w_landing_page_demo.website_session_id) as sessions,
 count(distinct bounced_sessions_only.website_session_id) as bounced_sessions
 from sessions_w_landing_page_demo
	left join bounced_sessions_only
    on sessions_w_landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
group by sessions_w_landing_page_demo.landing_page
order by sessions_w_landing_page_demo.website_session_id;

 select 
 sessions_w_landing_page_demo.landing_page,
 count(distinct sessions_w_landing_page_demo.website_session_id) as sessions,
 count(distinct bounced_sessions_only.website_session_id) as bounced_sessions,
 count(distinct bounced_sessions_only.website_session_id)/ count(distinct sessions_w_landing_page_demo.website_session_id) as bounced_rate
 from sessions_w_landing_page_demo
	left join bounced_sessions_only
    on sessions_w_landing_page_demo.website_session_id=bounced_sessions_only.website_session_id
group by sessions_w_landing_page_demo.landing_page
order by sessions_w_landing_page_demo.website_session_id;

-- Assignment: Can you pull bounce rates for traffic landing on the homepage? 
-- I would like to see three numbers…Sessions, Bounced Sessions, and % of Sessions which Bounced
-- Step 1: Finding the minumum website pageview id associate with each session we care about
use mavenfuzzyfactory;

 create temporary table first_pageviews
 select
  website_pageviews.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview_id
 from website_pageviews
 inner join website_sessions
 on website_sessions.website_session_id= website_pageviews.website_session_id
 and website_sessions.created_at < '2012-06-14'
 group by
 website_pageviews.website_session_id;
 
 select * from first_pageviews;
 -- Step 2 next we will brind the landing page to each session
   create temporary table sessions_w_home_landing_page
 select 
 first_pageviews.website_session_id,
 website_pageviews.pageview_url as landing_page
 from first_pageviews
 left join website_pageviews
 on website_pageviews.website_pageview_id= first_pageviews.min_pageview_id
 where website_pageviews.pageview_url= '/home';


 select * from sessions_w_home_landing_page;
 
-- Step 3 first i will show you all of the sessions. then we will limit to bounced sessions and create a temporary table
 Create temporary table bounced_sessions
 select sessions_w_home_landing_page.website_session_id,
 sessions_w_home_landing_page.landing_page,
 count(website_pageviews.website_pageview_id) as count_of_page_views
 from sessions_w_home_landing_page
 left join website_pageviews
 on website_pageviews.website_session_id= sessions_w_home_landing_page.website_session_id
 group by
 sessions_w_home_landing_page.website_session_id,
 sessions_w_home_landing_page.landing_page
 having count(website_pageviews.website_pageview_id)= 1;
 
 select * from bounced_sessions;
 
  select 
 sessions_w_home_landing_page.website_session_id,
 bounced_sessions.website_session_id as bounced_website_session_id
 from sessions_w_home_landing_page
	left join bounced_sessions
    on sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id
    order by sessions_w_home_landing_page.website_session_id;

 select 
sessions_w_home_landing_page.landing_page,
 count(distinct sessions_w_home_landing_page.website_session_id) as sessions,
 count(distinct bounced_sessions.website_session_id) as bounced_sessions,
 count(distinct bounced_sessions.website_session_id)/ count(distinct sessions_w_home_landing_page.website_session_id) as bounced_rate
 from sessions_w_home_landing_page
	left join bounced_sessions
    on sessions_w_home_landing_page.website_session_id=bounced_sessions.website_session_id
group by sessions_w_home_landing_page.landing_page
order by sessions_w_home_landing_page.website_session_id;

-- A.B Test Lander

-- Assignment:Based on your bounce rate analysis, we ran a new custom 
-- landing page (/lander-1) in a 50/50 test against the homepage (/home) for our gsearch nonbrand traffic.
-- Can you pull bounce rates for the two groups so we can evaluate the new page? Make sure to just look at the time
-- period where /lander-1 was getting traffic, so that it is a fair comparison

select min(created_at) as first_created_at,
min(website_pageview_id) as first_pageview_id
from website_pageviews
where pageview_url = '/lander-1' 
and created_at is not null 

select * from website_pageviews
where pageview_url = '/lander-1' 
order by created_at asc;

create temporary table first_pageviews_test
 select
  website_pageviews.website_session_id,
 min(website_pageviews.website_pageview_id) as min_pageview_id
 from website_pageviews
 inner join website_sessions
 on website_sessions.website_session_id= website_pageviews.website_session_id
 and website_sessions.created_at > '2012-06-19 00:35:53'
 and website_sessions.created_at < '2012-07-28'
 and utm_source = 'gsearch'
 and utm_campaign= 'nonbrand'
 group by
 website_pageviews.website_session_id;
 
create temporary table nonbrand_sessions_w_landing_page
 select 
first_pageviews_test.website_session_id,
 website_pageviews.pageview_url as landing_page
 from first_pageviews_test
 left join website_pageviews
 on website_pageviews.website_pageview_id= first_pageviews_test.min_pageview_id
 where website_pageviews.pageview_url= '/home' or website_pageviews.pageview_url = '/lander-1';
 
Create temporary table nonbrand_bounced_sessions
 select nonbrand_sessions_w_landing_page.website_session_id,
nonbrand_sessions_w_landing_page.landing_page,
 count(website_pageviews.website_pageview_id) as count_of_page_views
 from nonbrand_sessions_w_landing_page
 left join website_pageviews
 on website_pageviews.website_session_id= nonbrand_sessions_w_landing_page.website_session_id
 group by
nonbrand_sessions_w_landing_page.website_session_id,
nonbrand_sessions_w_landing_page.landing_page
 having count(website_pageviews.website_pageview_id)= 1;
 
  select 
nonbrand_sessions_w_landing_page.landing_page,
 count(distinct nonbrand_sessions_w_landing_page.website_session_id) as sessions,
 count(distinct nonbrand_bounced_sessions.website_session_id) as bounced_sessions,
 count(distinct nonbrand_bounced_sessions.website_session_id)/ count(distinct nonbrand_sessions_w_landing_page.website_session_id) as bounced_rate
 from nonbrand_sessions_w_landing_page
	left join nonbrand_bounced_sessions
    on nonbrand_sessions_w_landing_page.website_session_id=nonbrand_bounced_sessions.website_session_id
group by nonbrand_sessions_w_landing_page.landing_page
order by nonbrand_sessions_w_landing_page.website_session_id;
 
 
 -- Reports / Insights
-- Traffic Sources: gsearch nonbrand is the largest traffic contributor.
-- Conversion Rates: Overall session-to-order conversion below 4% for gsearch nonbrand. Desktop conversion better than mobile, 
-- guiding bid adjustments.
-- Bid Optimization: Adjusted bids based on conversion rate analysis. Weekly session trends confirmed sensitivity to bid changes.
-- Landing Page Analysis: Homepage bounce rate ~60%.
-- New custom landing page /lander-1







