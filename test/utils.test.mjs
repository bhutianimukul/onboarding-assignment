import { expect } from "chai";
import fs from "fs/promises";
import { Queue } from "../queue.js";
import { 
  readLastNLines, 
  pushToQueue, 
  getLatestnLines,
  queue
} from "../utils.js";

describe("Utils", () => {
  const testFilePath = "./test-log.txt";

  before(async () => {
    await fs.writeFile(testFilePath, "Line 1\nLine 2\nLine 3\n");
  });

  after(async () => {
    await fs.unlink(testFilePath);
  });

  describe("readLastNLines", () => {
    it("should read the last N lines from the log file", async () => {
      const lines = await readLastNLines(3, testFilePath);
      expect(lines.trim()).to.equal("Line 1\nLine 2\nLine 3");
    });

    it("should read less than N lines if fewer lines exist", async () => {
      await fs.writeFile(testFilePath, "Line 1\n");
      const lines = await readLastNLines(3, testFilePath);
      expect(lines).to.equal("Line 1\n");
    });
  });

  describe("pushToQueue", () => {
  
    beforeEach(() => {
      while (queue.size() > 0) {
        queue.dequeue();
      }
    });
  
    it("should add lines to the queue and maintain the limit", () => {
      pushToQueue("Line 1\nLine 2\nLine 3\n");
      
      expect(queue.size()).to.equal(3);
      expect(queue.list()).to.equal("Line 1\nLine 2\nLine 3");
  
      pushToQueue("Line 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10\nLine 11");
      expect(queue.size()).to.equal(10);
      expect(queue.list()).to.equal("Line 2\nLine 3\nLine 4\nLine 5\nLine 6\nLine 7\nLine 8\nLine 9\nLine 10\nLine 11");
    });
  });
});
