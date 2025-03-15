const express = require('express');
const path = require('path');
const fs = require('fs');

const cors = require('cors');

const app = express();
const port = 8300;

app.use(cors());

// Define the directory where images are stored
const imageDirectory = path.join(__dirname, 'userimage');

// Endpoint to serve images
app.get('/images/:filename', (req, res) => {
    const { filename } = req.params;
    const filePath = path.join(imageDirectory, filename);

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
