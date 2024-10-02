require "rspec"
require "./dice"

RSpec.describe Dice::DiceSet do
  dice = Dice::DiceSet.new

  describe "#initialize" do
    it "default throws" do
      expect(dice.max_throws).to eq(5)
      expect(dice.current_throw).to eq(5)
      expect(dice.values).to eq([])
    end

    it "allows for custom number of turns" do
      dice_custom = Dice::DiceSet.new(5)
      expect(dice_custom.max_throws).to eq(5)
      expect(dice_custom.current_throw).to eq(5)
    end
  end

  describe "#roll" do
    it "values should be an array" do
      dice.roll
      expect(dice.values.class).to eq(Array)
    end
    it "values should be less than or equal to max throws" do
      dice.roll
      expect(dice.values.length).to be <= dice.max_throws
    end
    it "values should between 1..6" do
      expect(dice.values).to all(be_between(1, 6).inclusive)
    end
  end
  describe "#score" do
    it "empty values" do
      expect(dice.score([])).to eq(0)
    end
    it "roll of 5" do
      expect(dice.score([5])).to eq(50)
    end
    it "roll of single 1" do
      expect(dice.score([1])).to eq(100)
    end
    it "roll of multiples and in triplets" do
      expect(dice.score([1, 1, 1])).to eq(1000)
      expect(dice.score([2, 2, 2])).to eq(200)
      expect(dice.score([3, 3, 3])).to eq(300)
      expect(dice.score([1, 5, 5, 1])).to eq(300)
    end
    it "single non scoring" do
      expect(dice.score([2, 3, 4, 6])).to eq(0)
    end

    describe "#compute_possible_rolls" do
      it "sets @current_throw to the number of non-scoring dice" do
        dice.instance_variable_set(:@values, [1, 2, 3, 4, 6])
        dice.compute_possible_rolls
        expect(dice.current_throw).to eq(4)

        # Example where all dice are scoring (three 1's and two 5's)
        dice.instance_variable_set(:@values, [1, 1, 1, 5, 5])
        dice.compute_possible_rolls
        expect(dice.current_throw).to eq(5)

        # Example where triplets are scoring
        dice.instance_variable_set(:@values, [2, 2, 2, 6, 6])
        dice.compute_possible_rolls
        expect(dice.current_throw).to eq(2)

        # Example where all are non scoring
        dice.instance_variable_set(:@values, [2, 2, 3, 6, 6])
        dice.compute_possible_rolls
        expect(dice.current_throw).to eq(dice.max_throws)
      end
    end
  end
end
