const express = require('express');
const mysql = require('mysql2/promise');

const cors = require('cors');

const app = express();
const port = 8500;

app.use(cors());

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

app.use(express.json());

app.post('/chatroom', async (req, res) => {
    const { userid, friendid } = req.body;

    try {
        const connection = await pool.getConnection();

        // Check if chatroom already exists with either combination of userid and friendid
        const [rows] = await connection.query(
            `SELECT chatid FROM chatroom 
            WHERE (FIND_IN_SET(?, chatuserid) > 0 AND FIND_IN_SET(?, chatuserid) > 0) 
            AND chattype = ?`,
            [userid, friendid, 'person']
        );

        if (rows.length > 0) {
            // Chatroom exists
            const chatid = rows[0].chatid;
            res.status(200).json({ chatid });
        } else {
            // Create a new chatroom
            await connection.query(
                'INSERT INTO chatroom (chatname, chatuserid, chattype) VALUES (?, ?, ?)',
                ['Chat with ' + friendid, `${userid},${friendid}`, 'person']
            );

            const [newRow] = await connection.query(
                `SELECT chatid FROM chatroom 
                WHERE (FIND_IN_SET(?, chatuserid) > 0 AND FIND_IN_SET(?, chatuserid) > 0) 
                AND chattype = ?`,
                [userid, friendid, 'person']
            );

            const chatid = newRow[0].chatid;
            res.status(200).json({ chatid });
        }

        connection.release();
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.listen(port, async () => {
    await initMySQL();
    console.log(`Server running on http://localhost:${port}`);
});
