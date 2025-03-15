const express = require('express');
const mysql = require('mysql2/promise');

const cors = require('cors');

const app = express();

app.use(cors());

const port = 8200;

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

app.get('/user/:userid', async (req, res) => {
    const { userid } = req.params;

    if (!userid) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    try {
        // 1. Retrieve the user's data
        const [userRows] = await pool.query('SELECT * FROM users WHERE userid = ?', [userid]);
        if (userRows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userRows[0];
        
        // 2. Retrieve the user's friends
        const friendIds = user.userfriend.split(',').filter(id => id.trim() !== '');
        let friends = [];
        
        if (friendIds.length > 0) {
            const [friendRows] = await pool.query('SELECT userid, username, userimage FROM users WHERE userid IN (?)', [friendIds]);
            friends = friendRows;
        }

        // 3. Send the response
        res.json({
            user: {
                userid: user.userid,
                username: user.username,
                userimage: user.userimage,
				usercountry: user.usercountry
            },
            friends: friends.map(friend => ({
                userid: friend.userid,
                username: friend.username,
                userimage: friend.userimage
            }))
        });
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});

app.listen(port, async () => {
    try {
        await initMySQL();
        console.log(`Server is running on port ${port}`);
    } catch (error) {
        console.error('Failed to connect to database:', error.message);
    }
});
