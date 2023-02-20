require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }

  describe "#show" do
    context "user anon" do
      it "kicks anon" do
        get :show, params: { id: game_w_questions.id }
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context "user sign_in" do
      before(:each) { sign_in user }

      it "show game" do
        get :show, params: {id: game_w_questions.id}
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)
        expect(response.status).to eq(200)
        expect(response).to render_template('show')
      end
    end
  end

  describe "#create" do
    context "user sign_in" do
      before(:each) { sign_in user }

      it "creates game" do
        generate_questions(15)

        post :create

        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.user).to eq(user)
        expect(response).to redirect_to(game_path(game))
        expect(flash[:notice]).to be
      end
    end
  end

  describe "#answer" do
    context "user sign_in" do
      before(:each) { sign_in user }

      it "return answers correct" do
        put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }
        game = assigns(:game)

        expect(game.finished?).to be_falsey
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be_truthy
      end
    end
  end
end
