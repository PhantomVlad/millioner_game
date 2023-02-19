require 'rails_helper'

RSpec.describe GameQuestion, type: :model do
  let(:game_question) { FactoryBot.create(:game_question, a: 2, b: 1, c: 4, d: 3) }

  describe "#variants" do
    it "return correct variants" do
      expect(game_question.variants).to eq({
                                             "a" => game_question.question.answer2,
                                             "b" => game_question.question.answer1,
                                             "c" => game_question.question.answer4,
                                             "d" => game_question.question.answer3,
                                           })

    end
  end

  describe "#answer_correct?" do
    it "return correct answer_correct?" do
      expect(game_question.answer_correct?("b")).to be true
    end
  end

  describe "correct #level & #text" do
    it 'return correct .level & .text' do
      expect(game_question.text).to eq(game_question.question.text)
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  context "game_question mechanics" do
    describe "#correct_answer_key" do
      it "correct .correct_answer_key" do
        expect(game_question.correct_answer_key).to eq("b")
      end
    end
  end
end
