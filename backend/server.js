// const express = require("express");
// const cors = require("cors");
// const { spawn } = require("child_process");
// const fs = require("fs");
// const path = require("path");

// const app = express();
// app.use(cors());
// app.use(express.json());

// app.post("/download", async (req, res) => {
//     const { url } = req.body;

//     if (!url) {
//         return res.status(400).json({ error: "URL is required" });
//     }

//     // Get video title
//     const titleProcess = spawn("yt-dlp", ["--print", "%(title)s", url]);

//     let videoTitle = "";
//     titleProcess.stdout.on("data", (data) => {
//         videoTitle += data.toString().trim();
//     });

//     titleProcess.on("close", (code) => {
//         if (code !== 0) {
//             return res.status(500).json({ error: "Failed to fetch video title" });
//         }

//         // Sanitize the title to make it a valid filename
//         const sanitizedTitle = videoTitle.replace(/[<>:"\/\\|?*]+/g, "");
//         const downloadPath = path.join(__dirname, `downloads/${sanitizedTitle}.mp4`);

//         if (!fs.existsSync("downloads")) {
//             fs.mkdirSync("downloads");
//         }

//         res.setHeader("Content-Type", "text/event-stream");
//         res.setHeader("Cache-Control", "no-cache");
//         res.setHeader("Connection", "keep-alive");

//         // Start download process
//         const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", downloadPath, url]);

//         ytdlp.stdout.on("data", (data) => {
//             const output = data.toString();
//             console.log(`yt-dlp: ${output}`);

//             // Extract progress percentage
//             const match = output.match(/\[download\]\s+([\d.]+)%/);
//             if (match) {
//                 const progress = parseFloat(match[1]);
//                 res.write(`data: ${JSON.stringify({ progress })}\n\n`);
//             }
//         });

//         ytdlp.on("close", (code) => {
//             if (code === 0) {
//                 res.write(`data: ${JSON.stringify({ status: "completed", filename: sanitizedTitle })}\n\n`);
//                 res.end();
//             } else {
//                 res.write(`data: ${JSON.stringify({ status: "error" })}\n\n`);
//                 res.end();
//             }
//         });
//     });
// });

// app.get("/download-file", (req, res) => {
//     const { filename } = req.query;
//     if (!filename) return res.status(400).json({ error: "Filename required" });

//     const filePath = path.join(__dirname, "downloads", `${filename}.mp4`);
//     if (!fs.existsSync(filePath)) {
//         return res.status(404).json({ error: "File not found" });
//     }

//     res.download(filePath, `${filename}.mp4`, (err) => {
//         if (err) console.error(err);
//         fs.unlinkSync(filePath); // Delete after sending
//     });
// });

// const PORT = 5000;
// app.listen(PORT, () => console.log(`Server running on port ${PORT}`));


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

    // Get video title
    const titleProcess = spawn("yt-dlp", ["--print", "%(title)s", url]);

    let videoTitle = "";
    titleProcess.stdout.on("data", (data) => {
        videoTitle += data.toString().trim();
    });

    titleProcess.on("close", (code) => {
        if (code !== 0) {
            return res.status(500).json({ error: "Failed to fetch video title" });
        }

        // Sanitize the title to make it a valid filename
        const sanitizedTitle = videoTitle.replace(/[<>:"\/\\|?*]+/g, "");
        const downloadPath = path.join(__dirname, `downloads/${sanitizedTitle}.mp4`);

        if (!fs.existsSync("downloads")) {
            fs.mkdirSync("downloads");
        }

        res.setHeader("Content-Type", "text/event-stream");
        res.setHeader("Cache-Control", "no-cache");
        res.setHeader("Connection", "keep-alive");

        // Start download process
        const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", downloadPath, url]);

        ytdlp.stdout.on("data", (data) => {
            const output = data.toString();
            console.log(`yt-dlp: ${output}`);

            // Extract progress percentage
            const match = output.match(/\[download\]\s+([\d.]+)%/);
            if (match) {
                const progress = parseFloat(match[1]);
                res.write(`data: ${JSON.stringify({ progress })}\n\n`);
            }
        });

        ytdlp.on("close", (code) => {
            if (code === 0) {
                res.write(`data: ${JSON.stringify({ status: "completed", filename: sanitizedTitle })}\n\n`);
                res.end();
            } else {
                res.write(`data: ${JSON.stringify({ status: "error" })}\n\n`);
                res.end();
            }
        });
    });
});

app.post("/download-reel", async (req, res) => {
    const { url } = req.body;

    if (!url) {
        return res.status(400).json({ error: "URL is required" });
    }

    // Get video title
    const titleProcess = spawn("yt-dlp", ["--print", "%(title)s", url]);

    let videoTitle = "";
    titleProcess.stdout.on("data", (data) => {
        videoTitle += data.toString().trim();
    });

    titleProcess.on("close", (code) => {
        if (code !== 0) {
            return res.status(500).json({ error: "Failed to fetch video title" });
        }

        // Sanitize the title to make it a valid filename
        const sanitizedTitle = videoTitle.replace(/[<>:"\/\\|?*]+/g, "");
        const downloadPath = path.join(__dirname, `downloads/${sanitizedTitle}.mp4`);

        if (!fs.existsSync("downloads")) {
            fs.mkdirSync("downloads");
        }

        res.setHeader("Content-Type", "text/event-stream");
        res.setHeader("Cache-Control", "no-cache");
        res.setHeader("Connection", "keep-alive");

        // Start download process
        const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", downloadPath, url]);

        ytdlp.stdout.on("data", (data) => {
            const output = data.toString();
            console.log(`yt-dlp: ${output}`);

            // Extract progress percentage
            const match = output.match(/\[download\]\s+([\d.]+)%/);
            if (match) {
                const progress = parseFloat(match[1]);
                res.write(`data: ${JSON.stringify({ progress })}\n\n`);
            }
        });

        ytdlp.on("close", (code) => {
            if (code === 0) {
                res.write(`data: ${JSON.stringify({ status: "completed", filename: sanitizedTitle })}\n\n`);
                res.end();
            } else {
                res.write(`data: ${JSON.stringify({ status: "error" })}\n\n`);
                res.end();
            }
        });
    });
});

app.get("/download-file", (req, res) => {
    const { filename } = req.query;
    if (!filename) return res.status(400).json({ error: "Filename required" });

    const filePath = path.join(__dirname, "downloads", `${filename}.mp4`);
    if (!fs.existsSync(filePath)) {
        return res.status(404).json({ error: "File not found" });
    }

    res.download(filePath, `${filename}.mp4`, (err) => {
        if (err) console.error(err);
        fs.unlinkSync(filePath); // Delete after sending
    });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));