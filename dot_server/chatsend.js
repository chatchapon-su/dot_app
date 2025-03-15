const express = require('express');
const mysql = require('mysql2/promise'); // ใช้ mysql2/promise สำหรับการเชื่อมต่อแบบ asynchronous

const cors = require('cors');

const app = express();
const port = 8800;

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

initMySQL(); // เรียกใช้งานฟังก์ชันเพื่อเชื่อมต่อฐานข้อมูล

app.use(express.json());

app.post('/messages', async (req, res) => {
  const { chatid, userID, message } = req.body;

  try {
    // ดำเนินการบันทึกข้อมูล
    const [result] = await pool.query(
      'INSERT INTO chatdata (chatid, chatuserid, chatmessage) VALUES (?, ?, ?)',
      [chatid, userID, message]
    );

    // ดึง chatdataid (ID ของแถวที่เพิ่งเพิ่ม) และส่งกลับไป
    const chatdataid = result.insertId;

    res.status(200).json({
      chatdataid: chatdataid,
      chatid: chatid,
    });
  } catch (error) {
    console.error('Error saving message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
});


app.listen(port, () => {
  console.log(`Server listening at http://localhost:${port}`);
});
