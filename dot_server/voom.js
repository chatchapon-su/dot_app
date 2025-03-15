const express = require('express');
const mysql = require('mysql2/promise');
const bodyParser = require('body-parser');

const cors = require('cors');

const app = express();
const port = 8990;

app.use(cors());

app.use(bodyParser.json());

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


app.get('/voom_posts/:userid', async (req, res) => {
    const { userid } = req.params;

    if (!userid) {
        return res.status(400).json({ message: 'User ID is required' });
    }

    try {
        const [userRows] = await pool.query('SELECT userfriend FROM users WHERE userid = ?', [userid]);

        if (userRows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userRows[0];
        const friendIds = user.userfriend ? user.userfriend.split(',').filter(id => id.trim() !== '') : [];

        let query = `
            SELECT voom.voomid, voom.voomtext, voom.voomprivacy, voom.userid, users.username, users.userimage
            FROM voom
            JOIN users ON voom.userid = users.userid
            WHERE voom.voomstatus != 'delete'
            AND (
                voom.voomprivacy = 'Public'
        `;

        if (friendIds.length > 0) {
            query += ` OR (voom.voomprivacy = 'Private' AND voom.userid IN (${friendIds.map(() => '?').join(',')}))`;
        }

        query += ` OR voom.userid = ?`;

        query += `)
            ORDER BY voom.voomid DESC
        `;

        const queryParams = [...friendIds, userid];

        const [voomRows] = await pool.query(query, queryParams);

        res.json({
            posts: voomRows.map(post => ({
                voomid: post.voomid,
                voomtext: post.voomtext,
                voomprivacy: post.voomprivacy,
                userid: post.userid,
                username: post.username,
                userimage: post.userimage
            }))
        });
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});



app.get('/selectvoom_posts/:userid/:userselectid', async (req, res) => {
    const { userid, userselectid } = req.params;

    if (!userid || !userselectid) {
        return res.status(400).json({ message: 'User ID and User Select ID are required' });
    }

    try {
        const [userRows] = await pool.query('SELECT userfriend FROM users WHERE userid = ?', [userid]);

        if (userRows.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        const user = userRows[0];
        const friendIds = user.userfriend ? user.userfriend.split(',').filter(id => id.trim() !== '') : [];

        let query = `
            SELECT voom.voomid, voom.voomtext, voom.voomprivacy, voom.userid, users.username, users.userimage
            FROM voom
            JOIN users ON voom.userid = users.userid
            WHERE voom.voomstatus != 'delete' AND voom.userid = ?
            AND (
                voom.voomprivacy = 'Public'
        `;

        if (friendIds.length > 0) {
            query += ` OR (voom.voomprivacy = 'Private' AND voom.userid IN (${friendIds.map(() => '?').join(',')}))`;
        }

        query += ` OR voom.userid = ?`;

        query += `)
            ORDER BY voom.voomid DESC
        `;

        const queryParams = [...friendIds];

        const [voomRows] = await pool.query(query, [userselectid, ...queryParams,userid]);

        res.json({
            posts: voomRows.map(post => ({
                voomid: post.voomid,
                voomtext: post.voomtext,
                voomprivacy: post.voomprivacy,
                userid: post.userid,
                username: post.username,
                userimage: post.userimage
            }))
        });
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});






app.post('/create_post', async (req, res) => {
    const { userid, voomtext, voomprivacy } = req.body;


    if (!userid || !voomtext || !voomprivacy) {
        return res.status(400).json({ message: 'Missing required fields' });
    }


    try {
        
        const [result] = await pool.query(
            'INSERT INTO voom (userid, voomtext, voomprivacy) VALUES (?, ?, ?)',
            [userid, voomtext, voomprivacy]
        );

        console.log(result.insertId);


        return res.json({
            message: 'Post created successfully',
            postId: result.insertId
        });
        
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});


app.put('/update_post_privacy', async (req, res) => {
    const { postId, newPrivacy } = req.body;


    if (!postId || !newPrivacy || !['Public', 'Private'].includes(newPrivacy)) {
        return res.status(400).json({ message: 'Invalid input' });
    }

    try {

        const [result] = await pool.query(
            'UPDATE voom SET voomprivacy = ? WHERE voomid = ?',
            [newPrivacy, postId]
        );

        if (result.affectedRows > 0) {
            res.json({ message: 'Post privacy updated successfully' });
        } else {
            res.status(404).json({ message: 'Post not found' });
        }
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Internal server error', error: error.message });
    }
});


app.put('/mark_post_as_deleted', async (req, res) => {
    const { postId } = req.body;

    if (!postId) {
        return res.status(400).json({ message: 'Post ID is required' });
    }

    try {
        const [result] = await pool.query(
            'UPDATE voom SET voomstatus = "delete" WHERE voomid = ?',
            [postId]
        );

        if (result.affectedRows > 0) {
            res.json({ message: 'Post marked as deleted successfully' });
        } else {
            res.status(404).json({ message: 'Post not found' });
        }
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
