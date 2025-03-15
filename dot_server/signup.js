const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const mysql = require('mysql2/promise');
const crypto = require('crypto');
const multer = require('multer');
const fs = require('fs');
const path = require('path');

const port = 8000;

const app = express();

app.use(bodyParser.json());
app.use(cors());

let pool = null;

const initMySQL = async () => {
    pool = await mysql.createPool({
        host: 'localhost',
        user: 'root',
        password: 'yourdatabasepassword',
        database: "dot",
        port: 3306
    });
};

const hashPassword = (password) => {
    return crypto.createHash('sha256').update(password).digest('hex');
};

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const dir = './userimage/';
        if (!fs.existsSync(dir)) {
            fs.mkdirSync(dir);
        }
        cb(null, dir);
    },
    filename: (req, file, cb) => {
        const userid = req.body.userid;
        const fileExtension = path.extname(file.originalname);
        const newFilename = `${userid}${fileExtension}`;
        cb(null, newFilename);
    }
});

const upload = multer({ storage: storage });

app.post('/signup', upload.single('userimage'), async (req, res) => {
    console.log('Request Body:', req.body);
    console.log('Uploaded File:', req.file);

    const { userid, useremail, username, userpassword, usercountry } = req.body;
    const userimage = req.file ? req.file.filename : null;

    if (!userid || !useremail || !username || !userpassword || !usercountry) {
        return res.status(400).json({ message: 'Missing required fields' });
    }

    if (!userimage) {
        return res.status(400).json({ message: 'File upload failed' });
    }

    const hashedPassword = hashPassword(userpassword);

    try {
        const [useridRows] = await pool.query('SELECT * FROM users WHERE userid = ?', [userid]);

        if (useridRows.length > 0) {
            return res.status(409).json({ message: 'User ID already exists' });
        }

        const [emailRows] = await pool.query('SELECT * FROM users WHERE useremail = ?', [useremail]);

        if (emailRows.length > 0) {
            return res.status(409).json({ message: 'User email already exists' });
        }

        // Insert new user
        const [result] = await pool.query(
            `INSERT INTO users (userid, userimage, useremail, username, userpassword, usercountry, userfriend, userrequest) 
             VALUES (?, ?, ?, ?, ?, ?, '', '')`,
            [userid, userimage, useremail, username, hashedPassword, usercountry]
        );
        res.status(201).json({ message: 'User created successfully' });
    } catch (error) {
        console.error('Database Error:', error.message);
        res.status(500).json({ message: 'Failed to create user', error: error.message });
    }
});

app.listen(port, async () => {
    try {
        await initMySQL();
        console.log(`Server Start On Port : ${port}`);
    } catch (error) {
        console.log("listen Error", error);
    }
});
