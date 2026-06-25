const express = require("express");
const router = express.Router();
const db = require("../db");


// CREATE ORDER
router.post("/", async (req, res) => {
    const { user_id, items } = req.body;

    try {
        // 1. Create order
        const order = await db.query(
            `INSERT INTO orders (user_id, status, total_amount)
             VALUES ($1, 'pending', 0)
             RETURNING *`,
            [user_id]
        );

        const orderId = order.rows[0].id;

        let total = 0;

        // 2. Insert order items
        for (let item of items) {
            const variant = await db.query(
                "SELECT price FROM product_variants WHERE id = $1",
                [item.variant_id]
            );

            const price = variant.rows[0].price;
            total += price * item.quantity;

            await db.query(
                `INSERT INTO order_items
                (order_id, product_id, variant_id, quantity, price_at_purchase)
                VALUES ($1,$2,$3,$4,$5)`,
                [
                    orderId,
                    item.product_id,
                    item.variant_id,
                    item.quantity,
                    price
                ]
            );
        }

        // 3. Update total
        await db.query(
            "UPDATE orders SET total_amount = $1 WHERE id = $2",
            [total, orderId]
        );

        res.json({ order_id: orderId, total });

    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
