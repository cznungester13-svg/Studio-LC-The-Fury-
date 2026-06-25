import pg from 'pg';
const { Pool } = pg;

// Initialize connection pool to your Render database
const pool = new Pool({
  connectionString: process.env.DATABASE_URL, 
  ssl: { rejectUnauthorized: false } // Required for Render host connections
});

export const createStoreProduct = async (req, res) => {
  const { title, description, category_id, brand_id, size, color, price, weight, quantity } = req.body;

  try {
    // Start a SQL Transaction so if one insert fails, they all roll back safely
    await pool.query('BEGIN');

    // 1. Insert into products table (Identified as STORE and instantly ACTIVE)
    const productQuery = `
      INSERT INTO products (title, description, category_id, brand_id, seller_type, listing_status)
      VALUES ($1, $2, $3, $4, 'STORE', 'ACTIVE')
      RETURNING product_id;
    `;
    const productResult = await pool.query(productQuery, [title, description, category_id, brand_id]);
    const productId = productResult.rows[0].product_id;

    // 2. Insert into product_variants table
    const variantQuery = `
      INSERT INTO product_variants (product_id, size, color, price, weight, is_active)
      VALUES ($1, $2, $3, $4, $5, TRUE)
      RETURNING variant_id;
    `;
    const variantResult = await pool.query(variantQuery, [productId, size, color, price, weight]);
    const variantId = variantResult.rows[0].variant_id;

    // 3. Insert into inventory table to lock down stock levels
    const inventoryQuery = `
      INSERT INTO inventory (variant_id, quantity, reserved_quantity)
      VALUES ($1, $2, 0);
    `;
    await pool.query(inventoryQuery, [variantId, quantity]);

    // Commit transaction to database
    await pool.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Store product, variant, and inventory created successfully!',
      productId,
      variantId
    });

  } catch (error) {
    // Cancel the transaction if anything went wrong to prevent partial data corruption
    await pool.query('ROLLBACK');
    console.error('Error in store product creation:', error);
    res.status(500).json({ success: false, error: 'Internal Server Error' });
  }
};
