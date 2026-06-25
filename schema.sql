CREATE TABLE products (
    product_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    -- Basic Product Information
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    subcategory VARCHAR(100),

    -- Pricing
    price DECIMAL(10,2) NOT NULL,
    original_price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'USD',

    -- Inventory
    quantity INTEGER DEFAULT 1,
    sku VARCHAR(100) UNIQUE,
    brand VARCHAR(100),

    -- Product Source
    listing_type VARCHAR(20) NOT NULL
        CHECK (listing_type IN ('STORE', 'RESALE')),

    -- Seller Information
    seller_id UUID,
    
    -- Product Condition
    condition VARCHAR(30)
        CHECK (
            condition IN (
                'NEW',
                'LIKE_NEW',
                'EXCELLENT',
                'GOOD',
                'FAIR',
                'POOR'
            )
        ),

    -- Images
    primary_image_url TEXT,
    
    -- Marketplace Status
    status VARCHAR(20) DEFAULT 'ACTIVE'
        CHECK (
            status IN (
                'ACTIVE',
                'PENDING_APPROVAL',
                'SOLD',
                'INACTIVE',
                'REMOVED'
            )
        ),

    -- Shipping
    weight DECIMAL(8,2),
    shipping_cost DECIMAL(10,2),

    -- Payout Tracking
    seller_payout_amount DECIMAL(10,2),
    seller_payout_status VARCHAR(20)
        CHECK (
            seller_payout_status IN (
                'PENDING',
                'PROCESSING',
                'PAID',
                'FAILED'
            )
        ),
    payout_date TIMESTAMP,

    -- Sale Tracking
    sold_date TIMESTAMP,

    -- Audit Fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    -- Optional FK to Users table
    CONSTRAINT fk_seller
        FOREIGN KEY (seller_id)
        REFERENCES users(user_id)
        ON DELETE SET NULL
);

CREATE TABLE product_images (
    image_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    image_url TEXT NOT NULL,
    display_order INTEGER DEFAULT 0,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE
);

CREATE TABLE categories (
    category_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category_name VARCHAR(100) UNIQUE NOT NULL,
    parent_category_id UUID,

    FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    order_status VARCHAR(30),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE marketplace_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL,
    order_id UUID NOT NULL,

    sale_price DECIMAL(10,2) NOT NULL,
    commission_amount DECIMAL(10,2) NOT NULL,
    seller_payout_amount DECIMAL(10,2) NOT NULL,

    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (product_id)
        REFERENCES products(product_id),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
);
    
