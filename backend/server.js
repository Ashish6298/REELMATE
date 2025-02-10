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

    // Fetch video title
    const titleProcess = spawn("yt-dlp", ["--print", "%(title)s", url]);

    let videoTitle = "";
    titleProcess.stdout.on("data", (data) => {
        videoTitle += data.toString().trim();
    });

    titleProcess.stderr.on("data", (data) => {
        console.error(`yt-dlp title error: ${data}`);
    });

    titleProcess.on("close", (code) => {
        if (code !== 0) {
            return res.status(500).json({ error: "Failed to fetch video title" });
        }

        // Replace invalid filename characters
        const sanitizedTitle = videoTitle.replace(/[<>:"\/\\|?*]+/g, "");
        const filePath = path.join(__dirname, `downloads/${sanitizedTitle}.mp4`);

        // Ensure downloads directory exists
        if (!fs.existsSync("downloads")) {
            fs.mkdirSync("downloads");
        }

        // Spawn yt-dlp process to download video
        const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", filePath, url]);

        ytdlp.stdout.on("data", (data) => {
            console.log(`yt-dlp: ${data}`);
        });

        ytdlp.stderr.on("data", (data) => {
            console.error(`yt-dlp error: ${data}`);
        });

        ytdlp.on("close", (code) => {
            if (code === 0) {
                res.download(filePath, `${sanitizedTitle}.mp4`, (err) => {
                    if (err) console.error(err);
                    fs.unlinkSync(filePath); // Delete file after sending
                });
            } else {
                res.status(500).json({ error: "Failed to download video" });
            }
        });
    });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));



