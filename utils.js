const fs = require("fs");
const fsP = require("fs/promises");
const { Queue } = require("./queue");
const { PassThrough } = require("stream");

const filename = "./log.txt";
const logLines = 10

const queueStream = new PassThrough();

const queue = new Queue();
async function readLastNLines(n, filePath) {
  const fstats = await fsP.stat(filePath);
  const size = fstats.size;

  const fileD = await fsP.open(filePath);
  const buf = Buffer.alloc(1);
  let count = 0;
  let offset = Math.max(0, size - 1);
  let val = "";
  while (offset >= 0 && count <= n) {
    await fileD.read(buf, 0, 1, offset); // size - 1
    if (String(buf) === "\n") {
      count++;
    }
    offset--;

    val = String(buf) + val;
  }

  return val;
}

(async function regularUpdates(n) {
  const fileD = await fsP.open(filename);
  const prevStat = await fsP.stat(filename);
  let prevSize = prevStat.size;
  const lastnLines = await readLastNLines(n, "./log.txt");
  pushToQueue(lastnLines);
  setInterval(async () => {
    const currStat = await fsP.stat(filename);
    const currSize = currStat.size;
    if (currSize > prevSize) {
      const buf = Buffer.alloc(currSize - prevSize);
      await fileD.read(buf, 0, currSize - prevSize, prevSize);
      prevSize = currSize;
      pushToQueue(String(buf));
      queueStream.write(String(buf));
    } else {
      if (prevSize > currSize) console.log("ALERT, File has been appended");
    }
  }, 1000);
})(logLines);

function pushToQueue(lines, n = logLines) {
  const lastLines = lines.trim().split("\n");
  lastLines.forEach((element) => {
    if (queue.size() >= n) queue.dequeue();
    queue.enqueue(element);
  });
}

function getLatestnLines() {
  const stream = new PassThrough();
  const lastnLines = queue.list();
  stream.write(lastnLines);
  queueStream.pipe(stream);
  return stream;
}
module.exports = { getLatestnLines, pushToQueue, readLastNLines, queue  };
