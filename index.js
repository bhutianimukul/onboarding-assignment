const app = require("./server.js");
const { io } = require("./socket.js");

app.listen(8080, () => {
  console.log("server started");
});

io.listen(3000);
