const express = require('express');
const path = require('path');
const fs = require('fs');

const cors = require('cors');

const app = express();
const port = 8300;

app.use(cors());

const imageDirectory = path.join(__dirname, 'userimage');

app.get('/images/:filename', (req, res) => {
    const { filename } = req.params;
    const filePath = path.join(imageDirectory, filename);

    fs.access(filePath, fs.constants.F_OK, (err) => {
        if (err) {
            return res.status(404).json({ message: 'Image not found' });
        }

        res.sendFile(filePath);
    });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
});
