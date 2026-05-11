-- ==========================================================
-- E-COMMERCE RAM PRICING INTELLIGENCE 2026: ANALYSIS QUERIES
-- ==========================================================

-- 1. Average Price per GB by Brand and Generation
SELECT 
    p.brand, 
    p.ram_generation,
    ROUND(AVG(l.price / p.capacity_gb), 2) AS avg_price_per_gb
FROM products p
JOIN listings l ON p.product_id = l.product_id
GROUP BY p.brand, p.ram_generation
ORDER BY avg_price_per_gb;

-- 2. Average Price by Brand
SELECT 
    p.brand,
    ROUND(AVG(l.price), 2) AS avg_price_brand  
FROM products p
JOIN listings l ON p.product_id = l.product_id
GROUP BY p.brand
ORDER BY avg_price_brand DESC;
 
-- 3. Top 10 Bestsellers
SELECT 
    p.brand, 
    p.ram_generation, 
    l.seller_id,
    SUM(l.sold) AS total_sold
FROM products p
JOIN listings l ON p.product_id = l.product_id
GROUP BY p.brand, p.ram_generation, l.seller_id
ORDER BY total_sold DESC 
LIMIT 10;

-- 4. Most Popular RAM Capacities
SELECT 
    p.capacity_gb,
    SUM(l.sold) AS total_sold
FROM listings l
JOIN products p ON p.product_id = l.product_id
WHERE p.capacity_gb IS NOT NULL
GROUP BY p.capacity_gb
ORDER BY total_sold DESC
LIMIT 10;

-- 5. Market Segment Performance (Enterprise vs. Consumer)
SELECT 
    CASE 
        WHEN p.is_bulk_server = 1 THEN 'Enterprise'
        ELSE 'Consumer' 
    END AS type_market,
    COUNT(*) AS listing_count,
    SUM(l.sold) AS total_sold,
    ROUND(AVG(l.price), 2) AS avg_price,
	ROUND(SUM(l.sold) /COUNT(*), 0) AS sold_per_listing
FROM listings l
JOIN products p ON p.product_id = l.product_id
GROUP BY type_market;

-- 6. Top 10 Sellers by Sales Volume  
SELECT 
    l.seller_id, 
    s.city,
    s.country,
    SUM(l.sold) AS total_sold,
    ROUND(AVG(l.price), 2) AS avg_price,
    ROUND(SUM(l.price * l.sold), 2) AS total_revenue,
    COUNT(DISTINCT l.title) AS total_listings
FROM listings l
JOIN sellers s ON s.product_id = l.product_id
GROUP BY l.seller_id, s.city, s.country
ORDER BY total_sold DESC
LIMIT 10;

-- 7. Top 10 Sellers by Total Revenue 
SELECT 
    l.seller_id, 
    s.city,
    s.country,
    SUM(l.sold) AS total_sold,
    ROUND(AVG(l.price), 2) AS avg_price,
    ROUND(SUM(l.price * l.sold), 2) AS total_revenue,
    COUNT(DISTINCT l.title) AS total_listings
FROM listings l
JOIN sellers s ON s.product_id = l.product_id
GROUP BY l.seller_id, s.city, s.country
ORDER BY total_revenue DESC
LIMIT 10;

-- 8. Sales Distribution by Country
SELECT 
    s.country,
    SUM(l.sold) AS total_sold
FROM listings l
JOIN sellers s ON s.product_id = l.product_id
GROUP BY s.country
ORDER BY total_sold DESC


-- 9. Condition Performance (New vs. Used vs. Other)
SELECT 
    l.condition,
	p.ram_generation,
    COUNT(*) AS listing_count,
    SUM(l.sold) AS total_sold,
    ROUND(AVG(l.price), 2) AS avg_price
FROM listings l
JOIN products p ON p.product_id = l.product_id
GROUP BY l.condition, p.ram_generation
ORDER BY total_sold DESC;

-- 10. Low Inventory & High Demand Items
SELECT 
    l.title,
    l.sold,
    l.available,
    l.price
FROM listings l
WHERE l.available BETWEEN 1 AND 5  
AND l.sold > 100
ORDER BY l.sold DESC;

-- 11. Market Competition Analysis (Price Spread by Brand & Capacity)
-- High price_spread indicates potential for competitive pricing strategy
SELECT 
    p.brand, 
    p.capacity_gb,
    COUNT(DISTINCT l.seller_id) AS seller_count, 
    ROUND(AVG(l.price), 2) AS avg_price,
    MAX(l.price) - MIN(l.price) AS price_spread,
    SUM(l.sold) AS total_sold
FROM listings l
JOIN products p ON p.product_id = l.product_id
WHERE p.capacity_gb IS NOT NULL
AND p.brand != 'Other'
GROUP BY p.brand, p.capacity_gb
ORDER BY seller_count DESC, total_sold;

--- 12 Comparison of DDR5 and DDR4 by average speed,
--- average price and average cost per 1 mhz

SELECT p.ram_generation,
       CASE 
          WHEN p.capacity_gb <= 8 THEN 'Entry-Level'
          WHEN p.capacity_gb <= 32 THEN 'Mainstream'
          WHEN p.capacity_gb <= 96 THEN 'Pro/Enthusiast'
          ELSE 'Enterprise'
          END AS capacity_segment,
       ROUND(AVG(bus_speed_mhz), 1) AS avg_speed,
	   ROUND(AVG(l.price), 2) AS avg_price,
	   ROUND(AVG(l.price / bus_speed_mhz), 4) AS avg_price_per_mhz,
	   SUM(l.sold) AS total_sold
FROM listings l
JOIN products p ON p.product_id = l.product_id
WHERE capacity_gb NOT IN (38)
GROUP BY p.ram_generation, capacity_segment
 