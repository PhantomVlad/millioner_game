require 'rails_helper'
require 'support/my_spec_helper'
RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  context "Game Factory" do
    it "Game.create_game_for_user! new correct game" do
      generate_questions(60)

      game = nil
      expect {
        game = Game.create_game_for_user!(user)
      }.to change(Game, :count).by(1).and(change(GameQuestion, :count).by(15))

      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      q = game_w_questions.current_game_question

      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)
      expect(game_w_questions.current_level).to eq(level + 1)

      expect(game_w_questions.current_game_question).not_to eq(q)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be false
    end

    describe "#take_money!" do
      it 'finishes the game' do
        q = game_w_questions.current_game_question
        game_w_questions.answer_current_question!(q.correct_answer_key)

        game_w_questions.take_money!

        prize = game_w_questions.prize
        expect(prize).to be > 0

        expect(game_w_questions.status).to eq :money
        expect(game_w_questions.finished?).to be true
        expect(user.balance).to eq prize
      end
    end

    describe '#current_game_question' do
      it "return current question" do
        expect(game_w_questions.current_game_question).to eq(game_w_questions.game_questions[0])
      end
    end

    describe '#previous_level' do
      it "return previous level" do
        expect(game_w_questions.previous_level).to be(-1)
      end
    end
  end

  describe "#status" do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be true
    end

    it ":fail" do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it ":timeout" do
      game_w_questions.is_failed = true
      game_w_questions.created_at = 1.hour.ago
      expect(game_w_questions.status).to eq(:timeout)
    end

    it ":won" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it ":money" do
      expect(game_w_questions.status).to eq(:money)
    end
  end
end
