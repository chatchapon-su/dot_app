const express = require('express');
const path = require('path');
const fs = require('fs');
const multer = require('multer');
const mysql = require('mysql2/promise'); // ใช้ mysql2/promise สำหรับการเชื่อมต่อแบบ asynchronous

const cors = require('cors');

const app = express();
const port = 8950;

app.use(cors());

// Define the directory where images are stored
const baseImageDirectory = path.join(__dirname, 'chatimg');

// Create MySQL connection pool
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

// Ensure the base image directory exists
if (!fs.existsSync(baseImageDirectory)) {
    fs.mkdirSync(baseImageDirectory);
}

// Configure multer for file upload
const storage = multer.diskStorage({
    destination: async (req, file, cb) => {
        const { chatid, chatdataid } = req.body;
        const chatFolder = path.join(baseImageDirectory, chatid);

        // Create directory for chatid if it doesn't exist
        if (!fs.existsSync(chatFolder)) {
            fs.mkdirSync(chatFolder);
        }

        cb(null, chatFolder);
    },
    filename: (req, file, cb) => {
        const { chatdataid } = req.body;
        const ext = path.extname(file.originalname);
        cb(null, `${chatdataid}${ext}`); // Rename file to chatdataid
    },
});

const upload = multer({ storage: storage });

// Endpoint to upload images
app.post('/upload_image', upload.single('image'), async (req, res) => {
    if (!req.file) {
        return res.status(400).json({ message: 'No file uploaded' });
    }

    const { chatid, chatdataid } = req.body;
    const imageUrl = `/images/${chatid}/${req.file.filename}`; // Construct the URL for the uploaded image

    try {
        const [result] = await pool.query(
            'UPDATE chatdata SET chatimage = ? WHERE chatdataid = ?',
            [req.file.filename, chatdataid]
        );
        res.status(200).json({ imageUrl: imageUrl });
    } catch (error) {
        console.error('Error updating database:', error);
        res.status(500).json({ message: 'Failed to update database' });
    }
});

// Endpoint to serve images
app.get('/images/:chatid/:filename', (req, res) => {
    const { chatid, filename } = req.params;
    const filePath = path.join(baseImageDirectory, chatid, filename);

    // Check if file exists
    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            return res.status(404).json({ message: 'Image not found' });
        }

        // Send the image file
        res.sendFile(filePath);
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
