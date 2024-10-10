const { io } = require("socket.io-client");
const ss = require("socket.io-stream");

const socket = io("ws://localhost:3000");
ss(socket).on("log", (strm) => {
  strm.on("data", (data) => {
    console.log(String(data).trim());
  });
});
