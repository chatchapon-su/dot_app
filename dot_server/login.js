// login.js
const express = require('express');
const mysql = require('mysql2/promise');
const crypto = require('crypto');

const cors = require('cors');

const port = 8100;

const app = express();

app.use(cors());
app.use(express.json());

let pool = null;

const initMySQL = async () => {
    pool = await mysql.createPool({
        host: 'localhost',
        user: 'root',
        password: 'yourdatabasepassword',
        database: 'dot',
        port: 3306
    });
};

const hashPassword = (password) => {
    return crypto.createHash('sha256').update(password).digest('hex');
};

app.post('/login', async (req, res) => {
    const { useremail, userpassword } = req.body;

    if (!useremail || !userpassword) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    const hashedPassword = hashPassword(userpassword);

    try {
        // Modified query to select the userid along with other fields
        const [rows] = await pool.query(
            'SELECT userid FROM users WHERE useremail = ? AND userpassword = ?',
            [useremail, hashedPassword]
        );

        if (rows.length > 0) {
            const user = rows[0]; // Assuming we have a single user
            res.status(200).json({ message: 'Login successful', userid: user.userid });
        } else {
            res.status(401).json({ message: 'Invalid credentials' });
        }
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Failed to login', error: error.message });
    }
});

app.listen(port, async () => {
    try {
        await initMySQL();
        console.log(`Server running on port ${port}`);
    } catch (error) {
        console.log('Error starting server:', error);
    }
});
