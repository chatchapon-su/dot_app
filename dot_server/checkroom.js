const express = require('express');
const mysql = require('mysql2/promise');

const cors = require('cors');

const app = express();
const port = 8600;

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

app.get('/chatrooms/:userid', async (req, res) => {
    const { userid } = req.params;

    try {
        const connection = await pool.getConnection();

        const [rows] = await connection.query(`
            SELECT chatroom.chatid, chatroom.chatuserid, MAX(chatdata.chatdataid) AS latest_chatdataid
            FROM chatroom
            LEFT JOIN chatdata ON chatroom.chatid = chatdata.chatid
            GROUP BY chatroom.chatid, chatroom.chatuserid
            ORDER BY latest_chatdataid DESC
        `);

        const chatRooms = [];

        for (const row of rows) {
            const chatid = row.chatid;
            const chatUsers = row.chatuserid.split(',');

            if (chatUsers.includes(userid)) {
                const otherUsers = chatUsers.filter(id => id !== userid);

                const [userRows] = await connection.query(
                    'SELECT userid, username, userimage FROM users WHERE userid IN (?)',
                    [otherUsers]
                );

                const [lastMessageRows] = await connection.query(
                    'SELECT chatmessage FROM chatdata WHERE chatid = ? ORDER BY chatdataid DESC LIMIT 1',
                    [chatid]
                );

                const lastMessage = lastMessageRows.length > 0 ? lastMessageRows[0].chatmessage : null;

                userRows.forEach(user => {
                    chatRooms.push({
                        chatid,
                        userID: user.userid,
                        userName: user.username,
                        userImage: user.userimage,
                        lastMessage
                    });
                });
            }
        }

        connection.release();
        res.status(200).json({ chatrooms: chatRooms });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


app.listen(port, async () => {
    await initMySQL();
    console.log(`Server running on http://localhost:${port}`);
});
