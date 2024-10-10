import { expect } from "chai";
import { Queue } from "../queue.js";

describe("Queue", () => {
  let queue;

  beforeEach(() => {
    queue = new Queue();
  });

  describe("enqueue", () => {
    it("should add an item to the queue", () => {
      queue.enqueue("item1");
      expect(queue.size()).to.equal(1);
      expect(queue.list()).to.include("item1");
    });

    it("should maintain the order of items", () => {
      queue.enqueue("item1");
      queue.enqueue("item2");
      expect(queue.list()).to.equal("item1\nitem2");
    });
  });

  describe("dequeue", () => {
    it("should remove the first item from the queue", () => {
      queue.enqueue("item1");
      queue.enqueue("item2");
      queue.dequeue();
      expect(queue.size()).to.equal(1);
      expect(queue.list()).to.equal("item2");
    });

    it("should not throw an error if called on an empty queue", () => {
      expect(() => queue.dequeue()).to.not.throw();
    });
  });

  describe("size", () => {
    it("should return the correct size of the queue", () => {
      expect(queue.size()).to.equal(0);
      queue.enqueue("item1");
      expect(queue.size()).to.equal(1);
      queue.enqueue("item2");
      expect(queue.size()).to.equal(2);
      queue.dequeue();
      expect(queue.size()).to.equal(1);
    });
  });

  describe("list", () => {
    it("should return a string of items in the queue", () => {
      queue.enqueue("item1");
      queue.enqueue("item2");
      expect(queue.list()).to.equal("item1\nitem2");
    });

    it("should return an empty string for an empty queue", () => {
      expect(queue.list()).to.equal("");
    });
  });
});
