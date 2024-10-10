class Queue {
    constructor() {
      this.arr = [];
    }
    enqueue(data) {
      this.arr.push(data);
    }
    dequeue() {
      this.arr.shift();
    }
    size() {
      return this.arr.length;
    }
    list() {
      return this.arr.join("\n");
    }
  }
  
  module.exports = { Queue };
  