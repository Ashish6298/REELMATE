// const express = require("express");
// const cors = require("cors");
// const { spawn, exec } = require("child_process");
// const fs = require("fs");
// const path = require("path");

// const app = express();
// app.use(cors());
// app.use(express.json());

// const FFMPEG_PATH = "D:\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\bin\\ffmpeg.exe";
// const DOWNLOADS_DIR = path.join(__dirname, "downloads");

// // Ensure downloads directory exists
// if (!fs.existsSync(DOWNLOADS_DIR)) {
//     fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
// }

// app.post("/download", async (req, res) => {
//     const { url } = req.body;

//     if (!url) {
//         return res.status(400).json({ error: "URL is required" });
//     }

//     // Get video title
//     exec(`yt-dlp --get-title "${url}"`, (error, stdout, stderr) => {
//         if (error) {
//             console.error(`Error fetching title: ${stderr}`);
//             return res.status(500).json({ error: "Failed to retrieve video title" });
//         }

//         let videoTitle = stdout.trim()
//             .replace(/[<>:"/\\|?*]/g, "") // Remove invalid characters
//             .replace(/\s+/g, "_"); // Replace spaces with underscores

//         const filePath = path.join(DOWNLOADS_DIR, `${videoTitle}.mp4`);
//         const videoTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_video.mp4`);
//         const audioTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_audio.mp4`);

//         // Download video (best quality, separate)
//         const ytdlpVideo = spawn("yt-dlp", [
//             "-f", "bv*",
//             "-o", videoTemp,
//             url
//         ]);

//         ytdlpVideo.on("close", (code) => {
//             if (code !== 0) {
//                 return res.status(500).json({ error: "Failed to download video" });
//             }

//             // Download audio (best quality, separate)
//             const ytdlpAudio = spawn("yt-dlp", [
//                 "-f", "ba",
//                 "-o", audioTemp,
//                 url
//             ]);

//             ytdlpAudio.on("close", (code) => {
//                 if (code !== 0) {
//                     return res.status(500).json({ error: "Failed to download audio" });
//                 }

//                 // Merge video and audio using FFmpeg
//                 const ffmpeg = spawn(FFMPEG_PATH, [
//                     "-i", videoTemp,
//                     "-i", audioTemp,
//                     "-c:v", "copy",
//                     "-c:a", "aac",
//                     "-strict", "experimental",
//                     filePath
//                 ]);

//                 ffmpeg.on("close", (code) => {
//                     if (code === 0) {
//                         fs.unlinkSync(videoTemp);
//                         fs.unlinkSync(audioTemp);

//                         res.download(filePath, `${videoTitle}.mp4`, (err) => {
//                             if (err) {
//                                 console.error(err);
//                                 return res.status(500).json({ error: "Failed to send file" });
//                             }
//                             fs.unlinkSync(filePath); // Delete file after sending
//                         });
//                     } else {
//                         res.status(500).json({ error: "Failed to merge video and audio" });
//                     }
//                 });
//             });
//         });
//     });
// });

// const PORT = 5000;
// app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

// const express = require("express");
// const cors = require("cors");
// const { spawn } = require("child_process");
// const fs = require("fs");
// const path = require("path");

// const app = express();
// app.use(cors());
// app.use(express.json());

// const DOWNLOADS_DIR = path.join(__dirname, "downloads");

// // Ensure downloads directory exists
// if (!fs.existsSync(DOWNLOADS_DIR)) {
//     fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
// }

// app.post("/download", (req, res) => {
//     const { url } = req.body;

//     if (!url) {
//         return res.status(400).json({ error: "URL is required" });
//     }

//     console.log("Downloading started...");

//     // Get video title
//     const ytdlpTitle = spawn("yt-dlp", ["--get-title", url]);
//     let videoTitle = "";

//     ytdlpTitle.stdout.on("data", (data) => {
//         videoTitle = data.toString().trim().replace(/[<>:"/\\|?*]/g, "").replace(/\s+/g, "_");
//     });

//     ytdlpTitle.on("close", () => {
//         const filePath = path.join(DOWNLOADS_DIR, `${videoTitle}.mp4`);
//         const ytdlp = spawn("yt-dlp", ["-f", "best", "-o", filePath, url]);

//         let progress = 0;

//         ytdlp.stdout.on("data", (data) => {
//             const output = data.toString();
//             const match = output.match(/(\d+(\.\d+)?)%/); // Extract percentage
//             if (match) {
//                 progress = parseFloat(match[1]);
//                 res.write(`data: ${progress}\n\n`); // Send progress update to frontend
//             }
//         });

//         ytdlp.on("close", (code) => {
//             if (code === 0) {
//                 console.log("Download completed successfully!");
//                 res.write(`data: completed\n\n`);
//                 res.end();
//             } else {
//                 res.status(500).json({ error: "Download failed" });
//             }
//         });
//     });
// });

// const PORT = 5000;
// app.listen(PORT, () => console.log(`Server running on port ${PORT}`));




// const express = require("express");
// const cors = require("cors");
// const { spawn, exec } = require("child_process");
// const fs = require("fs");
// const path = require("path");

// const app = express();
// app.use(cors());
// app.use(express.json());

// const FFMPEG_PATH = "D:\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\bin\\ffmpeg.exe";
// const DOWNLOADS_DIR = path.join(__dirname, "downloads");

// // Ensure downloads directory exists
// if (!fs.existsSync(DOWNLOADS_DIR)) {
//     fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
// }

// app.post("/download", async (req, res) => {
//     const { url } = req.body;

//     if (!url) {
//         return res.status(400).json({ error: "URL is required" });
//     }

//     exec(`yt-dlp --get-title "${url}"`, (error, stdout, stderr) => {
//         if (error) {
//             console.error(`Error fetching title: ${stderr}`);
//             return res.status(500).json({ error: "Failed to retrieve video title" });
//         }

//         let videoTitle = stdout.trim()
//             .replace(/[<>:"/\\|?*]/g, "")
//             .replace(/\s+/g, "_");

//         const filePath = path.join(DOWNLOADS_DIR, `${videoTitle}.mp4`);
//         const videoTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_video.mp4`);
//         const audioTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_audio.mp4`);

//         res.writeHead(200, {
//             "Content-Type": "application/json",
//             "Transfer-Encoding": "chunked",
//         });

//         function sendProgress(progress) {
//             res.write(JSON.stringify({ progress }) + "\n");
//         }

//         function extractProgress(data) {
//             const match = data.toString().match(/(\d+(\.\d+)?)%/);
//             return match ? parseFloat(match[1]) : null;
//         }

//         const ytdlpVideo = spawn("yt-dlp", ["-f", "bestvideo", "-o", videoTemp, url]);

//         ytdlpVideo.stdout.on("data", (data) => {
//             console.log(`Video Progress: ${data}`);
//             const progress = extractProgress(data);
//             if (progress !== null) sendProgress(progress);
//         });

//         ytdlpVideo.on("close", (code) => {
//             if (code !== 0) return res.end(JSON.stringify({ error: "Video download failed" }));

//             const ytdlpAudio = spawn("yt-dlp", ["-f", "bestaudio", "-o", audioTemp, url]);

//             ytdlpAudio.stdout.on("data", (data) => {
//                 console.log(`Audio Progress: ${data}`);
//                 const progress = extractProgress(data);
//                 if (progress !== null) sendProgress(progress + 50); // Shift audio progress after 50%
//             });

//             ytdlpAudio.on("close", (code) => {
//                 if (code !== 0) return res.end(JSON.stringify({ error: "Audio download failed" }));

//                 sendProgress(90); // Indicate merging

//                 const ffmpeg = spawn(FFMPEG_PATH, [
//                     "-i", videoTemp,
//                     "-i", audioTemp,
//                     "-c:v", "copy",
//                     "-c:a", "aac",
//                     "-strict", "experimental",
//                     filePath
//                 ]);

//                 ffmpeg.stdout.on("data", (data) => {
//                     console.log(`Merging: ${data}`);
//                 });

//                 ffmpeg.on("close", (code) => {
//                     if (code === 0) {
//                         fs.unlinkSync(videoTemp);
//                         fs.unlinkSync(audioTemp);
//                         sendProgress(100);
//                         res.end(JSON.stringify({ success: true, file: `${videoTitle}.mp4` }));
//                     } else {
//                         res.end(JSON.stringify({ error: "Merging failed" }));
//                     }
//                 });
//             });
//         });
//     });
// });

// const PORT = 5000;
// app.listen(PORT, () => console.log(`Server running on port ${PORT}`));




const express = require("express");
const cors = require("cors");
const { spawn, exec } = require("child_process");
const fs = require("fs");
const path = require("path");

const app = express();
app.use(cors());
app.use(express.json());

const FFMPEG_PATH = "D:\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\ffmpeg-2025-02-06-git-6da82b4485-full_build\\bin\\ffmpeg.exe";
const DOWNLOADS_DIR = path.join(__dirname, "downloads");

// Ensure downloads directory exists
if (!fs.existsSync(DOWNLOADS_DIR)) {
    fs.mkdirSync(DOWNLOADS_DIR, { recursive: true });
}

app.post("/download", async (req, res) => {
    const { url } = req.body;

    if (!url) {
        return res.status(400).json({ error: "URL is required" });
    }

    exec(`yt-dlp --get-title "${url}"`, (error, stdout, stderr) => {
        if (error) {
            console.error(`Error fetching title: ${stderr}`);
            return res.status(500).json({ error: "Failed to retrieve video title" });
        }

        let videoTitle = stdout.trim()
            .replace(/[<>:"/\\|?*]/g, "")
            .replace(/\s+/g, "_");

        const filePath = path.join(DOWNLOADS_DIR, `${videoTitle}.mp4`);
        const videoTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_video.mp4`);
        const audioTemp = path.join(DOWNLOADS_DIR, `${videoTitle}_audio.mp4`);

        res.writeHead(200, {
            "Content-Type": "application/json",
            "Transfer-Encoding": "chunked",
        });

        function sendProgress(progress) {
            res.write(JSON.stringify({ progress }) + "\n");
        }

        function extractProgress(data) {
            const match = data.toString().match(/(\d+(\.\d+)?)%/);
            return match ? parseFloat(match[1]) : null;
        }

        console.log("Starting video download...");

        const ytdlpVideo = spawn("yt-dlp", ["-f", "bestvideo", "-o", videoTemp, url]);

        ytdlpVideo.stdout.on("data", (data) => {
            console.log(`Video Progress: ${data}`);
            const progress = extractProgress(data);
            if (progress !== null) sendProgress(progress);
        });

        ytdlpVideo.on("close", (code) => {
            if (code !== 0) {
                res.end(JSON.stringify({ error: "Video download failed" }));
                return;
            }

            console.log("Video downloaded successfully. Starting audio download...");

            const ytdlpAudio = spawn("yt-dlp", ["-f", "bestaudio", "-o", audioTemp, url]);

            ytdlpAudio.stdout.on("data", (data) => {
                console.log(`Audio Progress: ${data}`);
                const progress = extractProgress(data);
                if (progress !== null) sendProgress(progress + 50); // Shift audio progress after 50%
            });

            ytdlpAudio.on("close", (code) => {
                if (code !== 0) {
                    res.end(JSON.stringify({ error: "Audio download failed" }));
                    return;
                }

                console.log("Audio downloaded successfully. Starting merging process...");
                sendProgress(90); // Indicate merging

                const ffmpeg = spawn(FFMPEG_PATH, [
                    "-i", videoTemp,
                    "-i", audioTemp,
                    "-c:v", "copy",
                    "-c:a", "aac",
                    "-strict", "experimental",
                    "-y", filePath
                ]);

                ffmpeg.stderr.on("data", (data) => {
                    console.log(`Merging: ${data}`);
                });

                ffmpeg.on("close", (code) => {
                    if (code === 0) {
                        fs.unlinkSync(videoTemp);
                        fs.unlinkSync(audioTemp);
                        sendProgress(100);
                        console.log("Merging completed successfully.");
                        res.end(JSON.stringify({ success: true, file: `${videoTitle}.mp4` }));
                    } else {
                        console.error("Merging failed!");
                        res.end(JSON.stringify({ error: "Merging failed" }));
                    }
                });
            });
        });
    });
});

const PORT = 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
