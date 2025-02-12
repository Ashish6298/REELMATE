require("dotenv").config(); // Load environment variables

const express = require("express");
const cors = require("cors");
const { spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());

const ytDlpPath = process.env.YTDLP_PATH || "yt-dlp"; // Default to "yt-dlp" if env is missing
const DOWNLOAD_DIR = path.join(__dirname, "downloads");

// Ensure the downloads directory exists
if (!fs.existsSync(DOWNLOAD_DIR)) {
    fs.mkdirSync(DOWNLOAD_DIR, { recursive: true });
}

// Function to get video title
const getVideoTitle = (url) => {
    return new Promise((resolve, reject) => {
        const titleProcess = spawn(ytDlpPath, ["--cookies", "cookies.txt", "--print", "%(title)s", url]);

        let videoTitle = "";
        titleProcess.stdout.on("data", (data) => {
            videoTitle += data.toString().trim();
        });

        titleProcess.on("close", (code) => {
            if (code !== 0 || !videoTitle) {
                return reject(new Error("Failed to fetch video title"));
            }
            resolve(videoTitle);
        });

        titleProcess.stderr.on("data", (data) => {
            console.error(`yt-dlp Error: ${data.toString()}`);
        });
    });
};

// Function to download video
const downloadVideo = (url, res) => {
    getVideoTitle(url)
        .then((videoTitle) => {
            const sanitizedTitle = videoTitle.replace(/[<>:"/\\|?*]+/g, "");
            const downloadPath = path.join(DOWNLOAD_DIR, `${sanitizedTitle}.mp4`);

            res.setHeader("Content-Type", "text/event-stream");
            res.setHeader("Cache-Control", "no-cache");
            res.setHeader("Connection", "keep-alive");

            const ytdlp = spawn(ytDlpPath, ["--cookies", "cookies.txt", "-f", "best", "-o", downloadPath, url]);

            ytdlp.stdout.on("data", (data) => {
                const output = data.toString();
                console.log(`yt-dlp: ${output}`);

                const match = output.match(/\[download\]\s+([\d.]+)%/);
                if (match) {
                    const progress = parseFloat(match[1]);
                    res.write(`data: ${JSON.stringify({ progress })}\n\n`);
                }
            });

            ytdlp.on("close", (code) => {
                if (code === 0) {
                    res.write(`data: ${JSON.stringify({ status: "completed", filename: sanitizedTitle })}\n\n`);
                } else {
                    res.write(`data: ${JSON.stringify({ status: "error" })}\n\n`);
                }
                res.end();
            });

            ytdlp.stderr.on("data", (data) => {
                console.error(`yt-dlp Error: ${data.toString()}`);
            });
        })
        .catch((error) => {
            console.error(error.message);
            res.status(500).json({ error: error.message });
        });
};

// Route for video download
app.post("/download", (req, res) => {
    const { url } = req.body;
    if (!url) return res.status(400).json({ error: "URL is required" });
    downloadVideo(url, res);
});

// Route for reel download (same as video download)
app.post("/download-reel", (req, res) => {
    const { url } = req.body;
    if (!url) return res.status(400).json({ error: "URL is required" });
    downloadVideo(url, res);
});

// Route for downloading a file
app.get("/download-file", (req, res) => {
    const { filename } = req.query;
    if (!filename) return res.status(400).json({ error: "Filename required" });

    const filePath = path.join(DOWNLOAD_DIR, `${filename}.mp4`);
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({ error: "File not found" });
    }

    res.download(filePath, `${filename}.mp4`, (err) => {
        if (err) console.error(err);
        fs.unlinkSync(filePath); // Delete after sending
    });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

