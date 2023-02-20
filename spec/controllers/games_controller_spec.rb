require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:user, is_admin: true) }
  let(:game_w_questions) { FactoryBot.create(:game_with_questions, user: user) }
  let(:game) { assigns(:game) }

  describe "#show" do
    context "user anon" do
      before { get :show, params: { id: game_w_questions.id } }

      it "return correct html status" do
        expect(response.status).not_to eq(200)
      end

      it "correct redirect to new_user" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "return alert in flash" do
        expect(flash[:alert]).to be
      end
    end

    context "user sign_in" do
      before(:each) { sign_in user }
      before { get :show, params: { id: game_w_questions.id } }

      it "game no finished" do
        expect(game.finished?).to be false
      end

      it "return correct user" do
        expect(game.user).to eq(user)
      end

      it "return html status 200" do
        expect(response.status).to eq(200)
      end

      it "render correct show" do
        expect(response).to render_template('show')
      end
    end
  end

  describe "#create" do
    context "user sign_in" do
      before(:each) { sign_in user }

      context 'and creating game' do
        before { generate_questions(15) }
        before { post :create }

        it 'game is not finished' do
          expect(game.finished?).to be false
        end

        it 'assigns user to game' do
          expect(game.user).to eq(user)
        end

        it 'redirects to game path' do
          expect(response).to redirect_to(game_path(game))
        end

        it 'renders flash notice' do
          expect(flash[:notice]).to be
        end
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
