-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- 1. USERS
-- =====================================================

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    first_name VARCHAR(100),
    last_name VARCHAR(100),

    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,

    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER'
        CHECK (role IN ('CUSTOMER', 'SELLER', 'ADMIN')),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. CATEGORIES
-- =====================================================

CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL,

    parent_category_id UUID,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_category_parent
        FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);

-- =====================================================
-- 3. BRANDS
-- =====================================================

CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    name VARCHAR(150) NOT NULL UNIQUE,

    description TEXT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. PRODUCTS
-- =====================================================

CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    sku VARCHAR(100) UNIQUE,

    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE,

    description TEXT,

    category_id UUID NOT NULL,
    brand_id UUID,

    seller_type VARCHAR(20) NOT NULL
        CHECK (seller_type IN ('STORE', 'RESELLER')),

    seller_id UUID,

    condition VARCHAR(30) DEFAULT 'NEW'
        CHECK (
            condition IN (
                'NEW',
                'LIKE_NEW',
                'EXCELLENT',
                'GOOD',
                'FAIR',
                'POOR',
                'FOR_PARTS'
            )
        ),

    listing_status VARCHAR(30) DEFAULT 'ACTIVE'
        CHECK (
            listing_status IN (
                'DRAFT',
                'PENDING_APPROVAL',
                'ACTIVE',
                'SOLD',
                'ARCHIVED',
                'REJECTED'
            )
        ),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_product_category
        FOREIGN KEY (category_id)
        REFERENCES categories(category_id),

    CONSTRAINT fk_product_brand
        FOREIGN KEY (brand_id)
        REFERENCES brands(brand_id),

    CONSTRAINT fk_product_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(user_id)
);

-- =====================================================
-- 5. PRODUCT VARIANTS
-- =====================================================

CREATE TABLE product_variants (
    variant_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    sku VARCHAR(100) UNIQUE,

    size VARCHAR(50),
    color VARCHAR(50),

    price DECIMAL(12,2) NOT NULL,

    weight DECIMAL(10,2),

    is_active BOOLEAN DEFAULT TRUE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_variant_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

-- =====================================================
-- 6. INVENTORY
-- =====================================================

CREATE TABLE inventory (
    inventory_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    variant_id UUID NOT NULL,

    quantity INTEGER NOT NULL DEFAULT 0,

    reserved_quantity INTEGER NOT NULL DEFAULT 0,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_inventory_variant
        FOREIGN KEY (variant_id)
        REFERENCES product_variants(variant_id)
        ON DELETE CASCADE
);

-- =====================================================
-- 7. PRODUCT IMAGES
-- =====================================================

CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    product_id UUID NOT NULL,

    image_url TEXT NOT NULL,

    display_order INTEGER DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_image_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

-- =====================================================
-- 8. SELLER LISTINGS
-- =====================================================

CREATE TABLE seller_listings (
    listing_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    seller_id UUID NOT NULL,

    product_id UUID NOT NULL,

    quantity INTEGER DEFAULT 1,

    asking_price DECIMAL(12,2) NOT NULL,

    condition VARCHAR(30)
        CHECK (
            condition IN (
                'LIKE_NEW',
                'EXCELLENT',
                'GOOD',
                'FAIR',
                'POOR',
                'FOR_PARTS'
            )
        ),

    approval_status VARCHAR(20)
        DEFAULT 'PENDING'
        CHECK (
            approval_status IN (
                'PENDING',
                'APPROVED',
                'REJECTED'
            )
        ),

    status VARCHAR(20)
        DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'SOLD',
                'REMOVED'
            )
        ),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_listing_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(user_id),

    CONSTRAINT fk_listing_product
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

CREATE INDEX idx_products_category
ON products(category_id);

CREATE INDEX idx_products_brand
ON products(brand_id);

CREATE INDEX idx_products_seller
ON products(seller_id);

CREATE INDEX idx_variants_product
ON product_variants(product_id);

CREATE INDEX idx_inventory_variant
ON inventory(variant_id);

CREATE INDEX idx_images_product
ON product_images(product_id);

CREATE INDEX idx_listings_seller
ON seller_listings(seller_id);

CREATE INDEX idx_listings_product
ON seller_listings(product_id);

--=====================================================
-- 2. CATEGORIES & BRANDS
--=====================================================

CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAYLT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE
    parent_id UUID REFERENCES categories(category_id) ON DELETE SET NULL
);

CREATE TABLE brands (
    brand_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE
);

--======================================================
-- 3. PRODUCTS & ATTRIBUTES
--======================================================

CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id UUID REFERENCES categories(category_id) ON DELETE SET NULL,
    brand_id UUID REFERENCES brands(brand_id) ON DELETE SET NULL,
    TITLE varchar(255) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    condition VARCHAR(50) NOT NULL, -- e.g., 'New', "Like New", 'Gently Used'
    status VARCHAR(20) DEFAULT 'AVAILABLE', -- e.g., 'AVAILABLE', 'SOLD', 'HIDDEN'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFWERENCES products(product_id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_attributes (
    attributes_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    key VARCHAR(50) NOT NULL, -- e.g., 'size', 'color', 'material'
    value VARCHAR(100) NOT NULL
);

--=======================================================
-- 4. ORDERS & ADDRESSES
--=======================================================

CREATE TABLE addresses (
    address_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOTNULL REFERENCES users(user_id) ON DELETE CASCADE,
    street_address TEXT NOT NULL,
    city_VARCHAR(100) NOT NULL
    state VARCHAR(100) NOT NULL
    postal_code VARCHAR(20) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA'
);

CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES addresses(address_id),
    shipping_address_id UUID REFERENCES users(user_id),
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING', -- e.g., 'PENDING', 'SHIPPED', 'DELIVERED'
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    order_item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(product_id ON DELETE SET NULL,
    price DECIMAL(10, 2) NOT NULL
);

--=======================================================
-- 5. WISHLISTS, REVIEWS, & PAYOUTS
--=======================================================

CREATE TABLE wishlists (
    wishlist_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, product_id)
);

CREATE TABLE reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reviewer_id UUID NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    product_id UUID NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
    rating INTEGER CHECK (rating >= 1 AND rating <=5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE seller_payouts (
    payout_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES users(user_id) ON DELETE SET NULL,
    order_id VIVID NOT NULL REFERENCES orders(order_id),
    amount_paid DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'PENDING', -- e.g., 'PENDING', 'PAID'
    processed_at TIMEATAMP
);

    
