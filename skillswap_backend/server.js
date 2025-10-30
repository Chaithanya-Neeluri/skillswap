import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import http from "http";
import { Server } from "socket.io";

// ✅ Import routes
import userRoutes from "./auth/userRoutes.js";
import profileRoutes from "./profile/profileRoutes.js";
import skillRoutes from "./skill/skillRoutes.js";
import searchRoutes from "./searchForTutor/search.js";
import chatRoutes from "./chat/chatRoute.js";
import videoRoutes from "./chat/videoRoutes.js"; // 👈 REST API for video calls

// ✅ Import socket modules
import handleVideoSocket from "./socket/videoSocket.js"; // 👈 New file we created

dotenv.config();
const app = express();
app.use(express.json());
app.use(cors());

// ✅ MongoDB connection
const MONGO_URI = process.env.MONGO_URI;
if (!MONGO_URI) {
  console.error("❌ MONGO_URI not found in .env file");
  process.exit(1);
}

mongoose
  .connect(MONGO_URI, { dbName: "skillswap" })
  .then(() => console.log("✅ MongoDB Connected to 'skillswap' database"))
  .catch((err) => console.error("❌ MongoDB Connection Error:", err));

// ✅ Express routes
app.use("/api/users", userRoutes);
app.use("/api/profile", profileRoutes);
app.use("/api/skill", skillRoutes);
app.use("/api/search", searchRoutes);
app.use("/api/chat", chatRoutes);
app.use("/api/video", videoRoutes); // 👈 REST routes for call history or logs

// ✅ Base route
app.get("/", (req, res) => {
  res.send("🚀 SkillSwap API is running successfully!");
});

// ✅ Create HTTP + WebSocket server
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

// ============================
// 🎯 SOCKET.IO LOGIC START
// ============================

// ✅ Chat socket setup
io.on("connection", (socket) => {
  console.log("🟢 User connected:", socket.id);

  // 🔸 Join room for text chat
  socket.on("joinRoom", (roomId) => {
    socket.join(roomId);
    console.log(`🟢 User ${socket.id} joined room ${roomId}`);
  });

  // 🔸 Handle text message sending
  socket.on("sendMessage", (data) => {
    const { roomId, senderId, receiverId, message } = data;

    io.to(roomId).emit("receiveMessage", {
      senderId,
      receiverId,
      message,
      createdAt: new Date(),
    });

    console.log(`💬 Message from ${senderId} to ${receiverId}: ${message}`);
  });

  socket.on("disconnect", () => {
    console.log("🔴 User disconnected:", socket.id);
  });
});

// ✅ Attach video socket handlers
handleVideoSocket(io); // 👈 Now video chat is live too!

// ============================
// 🎯 SOCKET.IO LOGIC END
// ============================

// ✅ Start the server
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
