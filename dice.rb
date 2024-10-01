module Dice
  class DiceSet
    attr_reader :values, :max_turns
    attr_accessor :current_turn

    def initialize(turns = 5)
      @max_turns = turns
      @current_turn = turns
      @values = []
    end

    def roll()
      @values = []
      @current_turn.times do |turn|
        @values << 1 + rand(6)
      end
      compute_possible_rolls
    end

    def score(dice = @values)
      freq = Hash.new(0)
      dice.each { |x| freq[x] += 1 }
      score = 0
      freq.each do |key, time|
        sets = time / 3
        remaining = time % 3
        if key == 1
          score += sets * 1000
          score += remaining * 100
        else score += key * sets * 100;         end
        score += remaining * 50 if key == 5
      end
      score
    end

    def compute_possible_rolls
      scoring_dices = get_scoring_dices
      non_scoring_dices = @values.length - scoring_dices
      @current_turn = non_scoring_dices.zero? ? @max_turns : non_scoring_dices
    end

    def is_scoring_die?(die)
      die == 1 || die == 5 || @values.count(die) >= 3
    end

    def get_scoring_dices
      @values.count { |die| is_scoring_die? die }
    end
  end
end
