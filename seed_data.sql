-- ============================================================
--  E-Commerce Sales Analysis — Seed Data (10,000+ transactions)
--  Run AFTER schema.sql
-- ============================================================

-- ─────────────────────────────────────────────
--  PRODUCTS  (30 SKUs across 6 categories)
-- ─────────────────────────────────────────────
INSERT INTO products (product_name, category, sub_category, unit_price, cost_price, stock_qty) VALUES
-- Electronics (high revenue contributors)
('iPhone 15 Pro 256GB',        'Electronics', 'Smartphones',    1099.00,  780.00, 500),
('Samsung Galaxy S24 Ultra',   'Electronics', 'Smartphones',     999.00,  700.00, 450),
('Sony WH-1000XM5 Headphones', 'Electronics', 'Audio',           349.00,  180.00, 800),
('Apple MacBook Air M3',       'Electronics', 'Laptops',        1299.00,  950.00, 300),
('Dell XPS 15 Laptop',         'Electronics', 'Laptops',        1499.00, 1050.00, 250),
('iPad Pro 12.9"',             'Electronics', 'Tablets',         999.00,  680.00, 400),
-- Clothing
('Nike Air Max 270',           'Clothing',    'Footwear',         150.00,   60.00,1200),
('Levi''s 501 Original Jeans', 'Clothing',    'Bottoms',           69.99,   25.00,2000),
('Adidas Ultraboost 23',       'Clothing',    'Footwear',         190.00,   75.00,1000),
('North Face Puffer Jacket',   'Clothing',    'Outerwear',        280.00,  110.00, 600),
-- Home & Kitchen
('Instant Pot Duo 7-in-1',     'Home',        'Kitchen',           99.00,   40.00,1500),
('Dyson V15 Vacuum',           'Home',        'Cleaning',         649.00,  350.00, 350),
('KitchenAid Stand Mixer',     'Home',        'Kitchen',          449.00,  220.00, 400),
('Nespresso Vertuo Next',      'Home',        'Kitchen',          159.00,   70.00, 900),
('Philips Hue Starter Kit',    'Home',        'Smart Home',       199.00,   90.00, 700),
-- Beauty & Personal Care
('La Mer Moisturizing Cream',  'Beauty',      'Skincare',         190.00,   50.00, 600),
('Dyson Airwrap Styler',       'Beauty',      'Hair Care',        599.00,  280.00, 400),
('Charlotte Tilbury Palette',  'Beauty',      'Makeup',            75.00,   22.00,1000),
('The Ordinary Serum Set',     'Beauty',      'Skincare',          45.00,   12.00,2000),
('Yves Saint Laurent Libre',   'Beauty',      'Fragrance',        120.00,   35.00, 800),
-- Sports & Outdoors
('Peloton Bike+',              'Sports',      'Fitness',         2495.00, 1600.00, 100),
('Garmin Forerunner 965',      'Sports',      'Wearables',        599.00,  320.00, 350),
('Hydro Flask 32oz',           'Sports',      'Hydration',         44.95,   14.00,3000),
('TRX Suspension Trainer',     'Sports',      'Fitness',          169.99,   65.00, 700),
('Coleman Camping Tent 4P',    'Sports',      'Outdoor',          189.00,   80.00, 500),
-- Books & Media
('Atomic Habits — James Clear','Books',       'Self-Help',         16.99,    5.00,5000),
('The Psychology of Money',    'Books',       'Finance',           15.99,    4.50,4000),
('Dune — Frank Herbert',       'Books',       'Fiction',           14.99,    4.00,4500),
('MasterClass Annual',         'Books',       'Online Learning',  180.00,   50.00,9999),
('Kindle Paperwhite',          'Electronics', 'E-Readers',        139.99,   72.00, 600);

-- ─────────────────────────────────────────────
--  CUSTOMERS  (500 synthetic records)
-- ─────────────────────────────────────────────
INSERT INTO customers (full_name, email, region, signup_date, age_group)
SELECT
    'Customer_' || gs AS full_name,
    'customer_' || gs || '@example.com' AS email,
    (ARRAY['North','South','East','West','International'])[1 + (gs % 5)] AS region,
    DATE '2023-01-01' + (gs * 2 % 365) AS signup_date,
    (ARRAY['18-24','25-34','35-44','45-54','55+'])[1 + (gs % 5)] AS age_group
FROM generate_series(1, 500) AS gs;

-- ─────────────────────────────────────────────
--  ORDERS  (~2,000 orders spanning Jan–Dec 2025)
-- ─────────────────────────────────────────────
INSERT INTO orders (customer_id, order_date, status, shipping_cost, discount_pct)
SELECT
    1 + (gs % 500)                                                  AS customer_id,
    DATE '2025-01-01' + (gs % 365)                                  AS order_date,
    (ARRAY['Completed','Completed','Completed','Returned','Cancelled'])[1+(gs%5)] AS status,
    ROUND((5 + (gs % 20))::NUMERIC, 2)                              AS shipping_cost,
    ROUND((gs % 30)::NUMERIC, 2)                                    AS discount_pct
FROM generate_series(1, 2000) AS gs;

-- ─────────────────────────────────────────────
--  ORDER ITEMS  (~10,000 line items)
-- ─────────────────────────────────────────────
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT
    1 + (gs % 2000)                          AS order_id,
    1 + (gs % 30)                            AS product_id,
    1 + (gs % 4)                             AS quantity,
    p.unit_price                             AS unit_price
FROM generate_series(1, 10000) AS gs
JOIN products p ON p.product_id = 1 + (gs % 30);
