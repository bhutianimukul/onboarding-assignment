const socket = require("socket.io");
const ss = require("socket.io-stream");
const { getLatestnLines } = require("./utils.js");

const io = new socket.Server({ cors: "*" });

io.on("connection", (socket) => {
  console.log("1 client got connected");
  var stream = ss.createStream();
  const lastLineStream = getLatestnLines();
  lastLineStream.pipe(stream);
  ss(socket).emit("log", stream);
});

module.exports = { io };
