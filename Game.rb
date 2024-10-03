require "./player.rb"
require "./dice.rb"

module Game
  class Game
    attr_reader :player_count

    def initialize(turns = 5)
      begin
        print "Enter the number of players: "
        @player_count = $stdin.gets.chomp.to_i
        puts @player_count
        raise ArgumentError if @player_count == nil || @player_count < 2
      rescue ArgumentError
        puts "Please enter a valid Player count."
        retry
      end
      @players = []
      @dice_obj = Dice::DiceSet.new turns
      @player_count.times do |count|
        @players << Player::Player.new(count + 1, turns)
      end
    end

    def start_game
      turn = 1
      while true
        last_round = is_last_round?
        puts "Turn #{turn}:"
        puts "--------"
        @players.each do |player|
          player.reset_score_and_take_turn @dice_obj
          puts ""
        end
        if last_round
          scores = @players.map { |player| player.accumulated_score }
          winner = scores.index(scores.max) + 1
          puts "We have a winner: player #{winner}"
          break
        end
        turn += 1
      end
    end

    def is_last_round?
      scores = @players.map { |player| player.accumulated_score }.select do |score|
        score >= 3000
      end
      scores.length > 0
    end
  end
end
