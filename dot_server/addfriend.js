const express = require('express');
const mysql = require('mysql2/promise');

const cors = require('cors');

const app = express();
const port = 8400;

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

app.post('/addfriend', async (req, res) => {
    const { userid, friendid } = req.body;

    try {
        const connection = await pool.getConnection();

        // Check if the friend exists
        const [friendRows] = await connection.query('SELECT * FROM users WHERE userid = ?', [friendid]);

        if (friendRows.length === 0) {
            return res.status(404).json({ message: 'Friend not found' });
        }

        const friend = friendRows[0];

        // Check if the current user's ID is in the friend's userrequest
        if (friend.userrequest && friend.userrequest.split(',').includes(userid)) {
            // Remove current user's ID from friend's userrequest
            const updatedUserRequest = friend.userrequest
                .split(',')
                .filter(id => id !== userid)
                .join(',');

            // Add current user's ID to friend's userfriend
            const updatedUserFriend = friend.userfriend
                ? friend.userfriend + ',' + userid
                : userid;

            // Update friend's userrequest and userfriend
            await connection.query(
                'UPDATE users SET userrequest = ?, userfriend = ? WHERE userid = ?',
                [updatedUserRequest, updatedUserFriend, friendid]
            );

            // Update current user's userfriend
            const [userRows] = await connection.query('SELECT * FROM users WHERE userid = ?', [userid]);
            const user = userRows[0];

            const updatedUserFriend2 = user.userfriend
                ? user.userfriend + ',' + friendid
                : friendid;

            await connection.query(
                'UPDATE users SET userfriend = ? WHERE userid = ?',
                [updatedUserFriend2, userid]
            );

        } else {
            // Add friend's ID to current user's userrequest
            const [userRows] = await connection.query('SELECT * FROM users WHERE userid = ?', [userid]);
            const user = userRows[0];

            const updatedUserRequest = user.userrequest
                ? user.userrequest + ',' + friendid
                : friendid;

            await connection.query(
                'UPDATE users SET userrequest = ? WHERE userid = ?',
                [updatedUserRequest, userid]
            );
        }

        connection.release();
        res.status(200).json({ message: 'Friend request handled successfully' });

    } catch (error) {
        console.error('Error handling friend request:', error.message);
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
