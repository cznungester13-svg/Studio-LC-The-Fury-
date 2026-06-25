const express = require("express");
const router = express.Router();
const db = require("../db");


// GET all products
router.get("/", async (req, res) => {
    try {
        const result = await db.query(`
            SELECT * FROM products
            ORDER BY created_at DESC
        `);

        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// GET single product (with variants + images)
router.get("/:id", async (req, res) => {
    const { id } = req.params;

    try {
        const product = await db.query(
            "SELECT * FROM products WHERE id = $1",
            [id]
        );

        const variants = await db.query(
            "SELECT * FROM product_variants WHERE product_id = $1",
            [id]
        );

        const images = await db.query(
            "SELECT * FROM product_images WHERE product_id = $1",
            [id]
        );

        res.json({
            product: product.rows[0],
            variants: variants.rows,
            images: images.rows
        });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});


// CREATE product (seller only)
router.post("/", async (req, res) => {
    const {
        seller_id,
        category_id,
        brand_id,
        title,
        description,
        base_price
    } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO products
            (seller_id, category_id, brand_id, title, description, base_price)
            VALUES ($1,$2,$3,$4,$5,$6)
            RETURNING *`,
            [seller_id, category_id, brand_id, title, description, base_price]
        );

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
