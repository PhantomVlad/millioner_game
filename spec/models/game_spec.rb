require 'rails_helper'
require 'support/my_spec_helper'
RSpec.describe Game, type: :model do
  let(:user) { FactoryBot.create(:user) }

  let(:game_w_questions) do
    FactoryBot.create(:game_with_questions, user: user)
  end

  let(:q) { game_w_questions.current_game_question }

  context 'Game Factory' do
    it 'Game.create_game! new correct game' do
      generate_questions(60)

      game = nil

      expect { game = Game.create_game_for_user!(user) }.to change(Game, :count).by(1)
      expect(game.user).to eq(user)
      expect(game.status).to eq(:in_progress)
      expect(game.game_questions.size).to eq(15)
      expect(game.game_questions.map(&:level)).to eq (0..14).to_a
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

  describe "#status" do
    before(:each) do
      game_w_questions.finished_at = Time.now
      expect(game_w_questions.finished?).to be true
    end

    it "return status :fail" do
      game_w_questions.is_failed = true
      expect(game_w_questions.status).to eq(:fail)
    end

    it "return status :timeout" do
      game_w_questions.is_failed = true
      game_w_questions.created_at = 1.hour.ago
      expect(game_w_questions.status).to eq(:timeout)
    end

    it "return status :won" do
      game_w_questions.current_level = Question::QUESTION_LEVELS.max + 1
      expect(game_w_questions.status).to eq(:won)
    end

    it "return status :money" do
      expect(game_w_questions.status).to eq(:money)
    end
  end

  describe "answer_current_question!" do
    before(:each) do
      game_w_questions.answer_current_question!(answer_key)
    end

    context "when answer is current" do
      let(:answer_key) { game_w_questions.current_game_question.correct_answer_key }

      context "when time no finished" do
        context "when no last question" do
          it "return current level" do
            expect(game_w_questions.current_level).to be(1)
          end

          it "return status game" do
            expect(game_w_questions.status).to eq(:in_progress)
          end
        end

        context "when last question" do
          let(:level) { Question::QUESTION_LEVELS.last }
          let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, current_level: level) }

          it "return current level" do
            expect(game_w_questions.current_level).to be(level + 1)
          end

          it "return status game 'won'" do
            expect(game_w_questions.status).to eq(:won)
          end

          it "return max prize" do
            expect(game_w_questions.prize).to be(1000000)
          end
        end
      end

      context "when time finished" do
        let!(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user, created_at: 1.hour.ago) }

        it "return finished true" do
          expect(game_w_questions.finished?).to be true
        end

        it "return status 'timeout'" do
          expect(game_w_questions.status).to eq(:timeout)
        end
      end
    end

    context "when answer isnt correct" do
      let(:answer_key) { [:a, :b, :c, :d].grep_v(game_w_questions.current_game_question.correct_answer_key).first }

      it "return finished true" do
        expect(game_w_questions.finished?).to be true
      end

      it "return status 'fail'" do
        expect(game_w_questions.status).to eq(:fail)
      end
    end
  end

  context 'game mechanics' do
    it 'answer correct continues game' do
      level = game_w_questions.current_level
      expect(game_w_questions.status).to eq(:in_progress)

      game_w_questions.answer_current_question!(q.correct_answer_key)

      expect(game_w_questions.current_level).to eq(level + 1)
      expect(game_w_questions.previous_game_question).to eq(q)
      expect(game_w_questions.current_game_question).not_to eq(q)
      expect(game_w_questions.status).to eq(:in_progress)
      expect(game_w_questions.finished?).to be_falsey
    end
  end
end
