
-- 1. Category translation table
ALTER TABLE category_translation
    ADD COLUMN IF NOT EXISTS category_name_clean TEXT;

UPDATE category_translation
SET category_name_clean = INITCAP(REPLACE(product_category_name_english, '_', ' '));

-- 2. Products table (Portuguese category name)
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS category_name_clean TEXT;

UPDATE products
SET category_name_clean = INITCAP(REPLACE(product_category_name, '_', ' '));

-- 3. Customers city
ALTER TABLE customers
    ADD COLUMN IF NOT EXISTS customer_city_clean TEXT;

UPDATE customers
SET customer_city_clean = INITCAP(customer_city);

-- 4. Sellers city
ALTER TABLE sellers
    ADD COLUMN IF NOT EXISTS seller_city_clean TEXT;

UPDATE sellers
SET seller_city_clean = INITCAP(seller_city);

-- 5. Geolocation city
ALTER TABLE geolocation
    ADD COLUMN IF NOT EXISTS geolocation_city_clean TEXT;

UPDATE geolocation
SET geolocation_city_clean = INITCAP(geolocation_city);

-- 6. Order status
ALTER TABLE orders
    ADD COLUMN IF NOT EXISTS order_status_clean TEXT;

UPDATE orders
SET order_status_clean = INITCAP(order_status);
