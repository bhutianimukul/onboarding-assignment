module Player
  class Player
    attr_reader :turn_score, :game_started, :name
    attr_accessor :accumulated_score

    def initialize(player_name, turns = 5)
      @name = player_name
      @turn_score = 0
      @game_started = false
      # @dice_obj = Dice::DiceSet.new turns
      @accumulated_score = 0
    end

    def reset_score_and_take_turn(dice_obj)
      @turn_score = 0
      take_turn(dice_obj)
      @accumulated_score += @turn_score if @game_started
      dice_obj.current_throw = dice_obj.max_throws # Reset the current throw to max throws
    end

    def take_turn(dice_obj)
      dice_obj.roll
      print "Player #{name} rolls: ", dice_obj.values.join(", "), "\n"
      score = dice_obj.score
      @turn_score += score
      @game_started = true if turn_score >= 300 && !game_started
      puts "Score in this round: #{score}"
      puts "Total score: #{score.zero? ? 0 : (@game_started ? @turn_score + @accumulated_score : 0)}" # current turn score + accumulated score till now if game started
      score.zero? ? reset_score : (take_turn dice_obj if play_again?(dice_obj))
    end

    def reset_score
      @turn_score = 0
      @accumulated_score = 0
    end

    def play_again?(dice_obj)
      print "Do you want to roll the non-scoring #{dice_obj.current_throw} dice? (y/n): "
      begin
        user_response = gets.chomp
        raise ArgumentError unless user_response.downcase == "y" || user_response.downcase == "n"
        user_response.downcase == "y"
      rescue ArgumentError
        puts "Please enter only y/n."
        retry
      end
    end
  end
end
