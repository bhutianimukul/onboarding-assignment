const express = require("express");
const app = express();
const path = require('path');

app.get("/log", (req, res) => {
  const filePath = path.join(__dirname, 'index.html');
  res.sendFile(filePath);
});

module.exports = app;
