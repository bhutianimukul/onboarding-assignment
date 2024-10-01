require("./dice")

module Player
  class Player
    attr_reader :turn_score, :game_started, :name
    attr_accessor :accumulated_score, :dice_obj

    def initialize(player_name, turns = 5)
      @name = player_name
      @turn_score = 0
      @game_started = false
      @dice_obj = Dice::DiceSet.new turns
      @accumulated_score = 0
    end

    def reset_score_and_take_turn
      @turn_score = 0
      take_turn
    end

    def take_turn
      @dice_obj.roll
      print "Player #{name} rolls: ", @dice_obj.values.join(", "), "\n"
      score = @dice_obj.score
      @turn_score += score
      @game_started = true if turn_score >= 300 && !game_started
      puts "Score in this round: #{score}"
      puts "Total score: #{@turn_score + @accumulated_score}" # current turn score + accumulated score till now
      score.zero? ? @turn_score = 0 : (take_turn if play_again?)
    end

    def play_again?
      print "Do you want to roll the non-scoring #{@dice_obj.current_turn} dice? (y/n): "
      begin
        user_response = gets.chomp
        raise ArgumentError if user_response.downcase == "y" || user_response.downcase == "n"
      rescue ArgumentError
        puts "Please enter only y/n."
        retry
      end
    end
  end
end
