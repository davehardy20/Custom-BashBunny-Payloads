const express = require('express');
const multer = require('multer');

const app = express();
const multer
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, './uploads/')
    },
    filename: function (req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now())
    }
})
const upload = multer({ storage })

app.route('/')
.post(upload.single('contact'), (req, res) => {
    res.send("Thanks")
})

app.listen(80, () => {
    console.log("Listening on port 80")
})