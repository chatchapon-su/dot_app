const express = require('express');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');

const cors = require('cors');

const app = express();
const port = 8900;

app.use(cors());

app.use(bodyParser.json());

const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'yourdatabasepassword',
    database: 'dot',
    port: 3306
});

app.post('/getUserProfile', async (req, res) => {
    const { userId } = req.body;

    if (!userId) {
        return res.status(400).send('User ID is required');
    }

    try {
        const queryString = 'SELECT username, userimage, useremail, usercountry FROM users WHERE userid = ?';
        const [rows] = await pool.query(queryString, [userId]);

        if (rows.length > 0) {
            res.status(200).json(rows[0]);
        } else {
            res.status(404).send('User not found');
        }
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).send('Database error');
    }
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
