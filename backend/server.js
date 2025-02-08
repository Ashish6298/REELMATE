const express = require("express");
const cors = require("cors");
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());

app.post("/download", async (req, res) => {
    const { url } = req.body;

    if (!url) {
        return res.status(400).json({ error: "URL is required" });
    }

    const videoID = new Date().getTime(); // Unique filename
    const filePath = path.join(__dirname, `downloads/${videoID}.mp4`);

    // Ensure downloads directory exists
    if (!fs.existsSync("downloads")) {
        fs.mkdirSync("downloads");
    }

    // Spawn yt-dlp process
    const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", filePath, url]);

    ytdlp.stdout.on("data", (data) => {
        console.log(`yt-dlp: ${data}`);
    });

    ytdlp.stderr.on("data", (data) => {
        console.error(`yt-dlp error: ${data}`);
    });

    ytdlp.on("close", (code) => {
        if (code === 0) {
            res.download(filePath, `${videoID}.mp4`, (err) => {
                if (err) console.error(err);
                fs.unlinkSync(filePath); // Delete file after sending
            });
        } else {
            res.status(500).json({ error: "Failed to download video" });
        }
    });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));


