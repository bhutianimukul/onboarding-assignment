require "rspec"
require "./game.rb"

RSpec.describe Game::Game do
  before do
    # $stdin = StringIO.new("3\n")
    allow($stdin).to receive(:gets).and_return("3\n")
  end
  describe "#initialize" do
    context "when a valid number of players is provided" do
      it "initializes player_count with the correct number" do
        game = Game::Game.new
        expect(game.instance_variable_get(:@player_count)).to eq(3)
      end

      it "creates the correct number of players array" do
        game = Game::Game.new
        expect(game.instance_variable_get(:@players).size).to eq(3)
      end
      it "creates Player instances with the correct names" do
        game = Game::Game.new
        players = game.instance_variable_get(:@players)
        expect(players.map(&:name)).to eq([1, 2, 3])
      end
      context "when an invalid player count is provided" do
        before do
          allow($stdin).to receive(:gets).and_return("1\n", "3\n") # First invalid input, then valid input
        end

        it "raises an ArgumentError and prompts again" do
          expect { Game::Game.new }.to output(
            /Please enter a valid Player count/
          ).to_stdout
        end
      end
      it "initializes player_count with the correct number after retry" do
        game = Game::Game.new
        expect(game.instance_variable_get(:@player_count)).to eq(3)
      end
    end
  end
  describe "#is_last_round?" do
    before do
      allow($stdin).to receive(:gets).and_return("3\n")
    end

    context "when no player has reached 3000 points" do
      it "returns false" do
        game = Game::Game.new
        player1 = double("Player", accumulated_score: 2500)
        player2 = double("Player", accumulated_score: 2900)
        game.instance_variable_set(:@players, [player1, player2])
        expect(game.is_last_round?).to be false
      end
    end

    context "when one player has reached 3000 points" do
      it "returns true" do
        game = Game::Game.new
        player1 = double("Player", accumulated_score: 3400)
        player2 = double("Player", accumulated_score: 2900)
        game.instance_variable_set(:@players, [player1, player2])
        expect(game.is_last_round?).to be true
      end
    end
  end
end
