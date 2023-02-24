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

  describe "#level" do
    it 'return correct .text' do
      expect(game_question.text).to eq(game_question.question.text)

    end
  end

  describe "#text" do
    it 'return correct .level' do
      expect(game_question.level).to eq(game_question.question.level)
    end
  end

  describe "#correct_answer_key" do
    it "return correct .correct_answer_key" do
      expect(game_question.correct_answer_key).to eq("b")
    end
  end

  describe "#add_audience_help" do
    context "game hasnt audience hash" do
      it "return help_hash hasnt :autidence_help" do
        expect(game_question.help_hash).not_to include(:audience_help)
      end
    end

    context "correct audience hash" do
      before { game_question.add_audience_help }

      it "return help_hash has :audience_help" do
        expect(game_question.help_hash).to include(:audience_help)
      end

      it "return a,b,c,d in auudirence_help keys" do
        expect(game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
      end
    end
  end

  describe "#help_hash" do
    context "correct help hash" do
      before { game_question.help_hash[:test1] = "test 1" }

      it "return true key" do
        expect(game_question.help_hash).to include(:test1)
      end

      it "return true meaning" do
        expect(game_question.help_hash[:test1]).to eq("test 1")
      end
    end

    context "correct fifty-fifty" do
      before { game_question.add_fifty_fifty}

      it "correct add fifty-fifty" do
        expect(game_question.help_hash).to include(:fifty_fifty)
      end

      it "true include 'b' - true answer" do
        expect(game_question.help_hash[:fifty_fifty]).to include('b')
      end

      it "return 2 answers" do
        expect(game_question.help_hash[:fifty_fifty].size).to eq 2
      end
    end
  end

  describe "#add_friend_call" do
    before { game_question.add_friend_call }

    it 'help_hash includes fifty_fifty' do
      expect(game_question.help_hash).to include(:friend_call)
    end

    it 'contains answer key' do
      expect(game_question.help_hash[:friend_call]).to include('A').or(include('B')).or(include('C')).or(include('D'))
    end
  end
end
