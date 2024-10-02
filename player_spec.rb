require "rspec"
require "./player"

RSpec.describe Player::Player do
  describe "#initialize" do
    it "initializes with correct attributes" do
      player = Player::Player.new("Mukul", 5)
      expect(player.name).to eq("Mukul")
      expect(player.turn_score).to eq(0)
      expect(player.accumulated_score).to eq(0)
      expect(player.game_started).to eq(false)
    end
  end
  describe "#take_turn" do
    player = Player::Player.new("Mukul", 5)
    let(:dice_obj) { double("Dice::DiceSet") }
    before do
      allow(dice_obj).to receive(:roll)
      allow(dice_obj).to receive(:values).and_return([1, 2, 3, 4, 5])
      allow(dice_obj).to receive(:score).and_return(0)
      allow(dice_obj).to receive(:current_throw)
    end
    context "when score is zero" do
      it "resets the turn score to zero and ends the turn" do
        expect { player.take_turn(dice_obj) }.to output(
          /Player Mukul rolls: 1, 2, 3, 4, 5\nScore in this round: 0\nTotal score: 0\n/
        ).to_stdout

        expect(player.turn_score).to eq(0)
      end
    end
    context "when score is greater than zero" do
      it "game not started if score < 300 and no next roll" do
        allow(player).to receive(:gets).and_return("n\n")
        allow(dice_obj).to receive(:score).and_return(100)
        player.take_turn(dice_obj)
        expect(player.turn_score).to eq(100)
        player.instance_variable_set(:@turn_score, 0) ## setting 0 because resetting in done in reset function
        expect(player.game_started).to eq(false)
      end

      it "adds the score to the turn score and check if game started" do
        allow(player).to receive(:gets).and_return("n\n")
        allow(dice_obj).to receive(:score).and_return(300)
        player.take_turn(dice_obj)
        expect(player.turn_score).to eq(300)
        expect(player.game_started).to eq(true)
      end
      it "turn score added 100 and game  started" do
        allow(player).to receive(:gets).and_return("n\n")
        allow(dice_obj).to receive(:score).and_return(100)
        player.take_turn(dice_obj)
        expect(player.turn_score).to eq(400)
        expect(player.game_started).to eq(true)
      end
    end
    describe "#play_again?" do
      context "when user inputs 'y'" do
        before do
          allow(player).to receive(:gets).and_return("y\n") # Simulate user input for 'yes'
        end

        it "returns true" do
          expect(player.play_again?(dice_obj)).to be true
        end
      end

      context "when user inputs 'n'" do
        before do
          allow(player).to receive(:gets).and_return("n\n") # Simulate user input for 'no'
        end

        it "returns false" do
          expect(player.play_again?(dice_obj)).to be false
        end
      end

      context "when user inputs invalid option" do
        before do
          allow(player).to receive(:gets).and_return("invalid\n", "y\n") # First invalid, then valid input
        end

        it "prompts again until valid input is received" do
          expect { player.play_again?(dice_obj) }.to output(/Please enter only y\/n/).to_stdout
          expect(player.play_again?(dice_obj)).to be true # Since the second input is 'y'
        end
      end
    end
  end
end
