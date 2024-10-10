const fs = require("fs");
const fsP = require("fs/promises");
const { Queue } = require("./queue");
const { PassThrough } = require("stream");

const filename = "./log.txt";

const queueStream = new PassThrough();

const queue = new Queue();
async function readLastNLines(n) {
  const fstats = await fsP.stat(filename);
  const size = fstats.size;

  const fileD = await fsP.open(filename);
  const buf = Buffer.alloc(1);
  let count = 0;
  let offset = Math.max(0, size - 1);
  let val = "";
  while (offset >= 0 && count <= 10) {
    await fileD.read(buf, 0, 1, offset); // size - 1
    if (String(buf) === "\n") {
      count++;
    }
    offset--;

    val = String(buf) + val;
  }

  return val;
}

(async function regularUpdates() {
  const fileD = await fsP.open(filename);
  const prevStat = await fsP.stat(filename);
  let prevSize = prevStat.size;
  const lastnLines = await readLastNLines(10);
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
})();

function pushToQueue(lines) {
  const lastLines = lines.trim().split("\n");
  lastLines.forEach((element) => {
    if (queue.size() >= 10) queue.dequeue();
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
module.exports = { getLatestnLines };
