const express = require("express");
const router = express.Router();
const db = require("../db");


// GET users (admin/test only)
router.get("/", async (req, res) => {
    const result = await db.query("SELECT id, name, email, role FROM users");
    res.json(result.rows);
});


// CREATE user (signup)
router.post("/", async (req, res) => {
    const { name, email, password_hash } = req.body;

    try {
        const result = await db.query(
            `INSERT INTO users (name, email, password_hash, role)
             VALUES ($1,$2,$3,'customer')
             RETURNING id, name, email`,
            [name, email, password_hash]
        );

        res.json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
