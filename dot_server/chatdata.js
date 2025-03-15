const express = require('express');
const mysql = require('mysql2/promise');

const cors = require('cors');

const app = express();
const port = 8700;

app.use(cors());

let pool;

const initMySQL = async () => {
    pool = await mysql.createPool({
        host: 'localhost',
        user: 'root',
        password: 'yourdatabasepassword',
        database: 'dot',
        port: 3306
    });
};

// เรียกใช้ฟังก์ชัน initMySQL เพื่อเชื่อมต่อกับฐานข้อมูล
initMySQL().catch(err => {
    console.error('Error initializing MySQL:', err);
    process.exit(1);
});

app.use(express.json());

app.get('/messages/:chatId', async (req, res) => {
    const { chatId } = req.params;
    const { userid } = req.query;  // รับ userid จาก query parameter

    try {
        const connection = await pool.getConnection();

        // ดึงข้อมูล username และ userimage ของผู้ใช้ปัจจุบัน
        const [userRows] = await connection.query(
            'SELECT username, userimage FROM users WHERE userid = ?',
            [userid]
        );

        if (userRows.length === 0) {
            connection.release();
            return res.status(404).json({ error: 'User not found' });
        }

        const { username, userimage } = userRows[0];

        // ใช้ JOIN เพื่อดึงข้อมูลจากตาราง users พร้อมกับตาราง chatdata
        const query = `
            SELECT chatdata.*, users.username, users.userimage
            FROM chatdata
            JOIN users ON chatdata.chatuserid = users.userid
            WHERE chatdata.chatid = ?
            ORDER BY chatdata.chatdataid ASC
        `;
        const [rows] = await connection.query(query, [chatId]);
        connection.release();

        if (rows.length > 0) {
            res.json({ 
                messages: rows, 
                currentUser: {
                    username,
                    userimage
                }
            });
            console.log('Messages retrieved successfully');
        }// else {
        //    res.status(404).json({ error: 'Chat ID not found' });
        //}
    } catch (err) {
        console.error('Error fetching messages:', err);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
