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

      it "alien game" do
        alien_game = FactoryBot.create(:game_with_questions)

        get :show, params: { id: alien_game.id }

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    context "user sign_in" do
      before { sign_in user }
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

      it "alien game" do
        alien_game = FactoryBot.create(:game_with_questions)

        get :show, params: { id: alien_game.id }

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end
  end

  describe "#create" do
    context "user sign_in" do
      before { sign_in user }

      context "creating game" do
        before { generate_questions(15) }
        before { post :create }

        it "game is not finished" do
          expect(game.finished?).to be false
        end

        it "assigns user to game" do
          expect(game.user).to eq(user)
        end

        it "redirects to game path" do
          expect(response).to redirect_to(game_path(game))
        end

        it "renders flash notice" do
          expect(flash[:notice]).to be
        end
      end

      context "one more game is not finished" do
        it "try to create second game" do
          expect(game_w_questions.finished?).to be_falsey
          expect { post :create }.to change(Game, :count).by(0)

          game = assigns(:game)
          expect(game).to be_nil

          expect(response).to redirect_to(game_path(game_w_questions))
          expect(flash[:alert]).to be
        end
      end
    end

    context "user not sign_in" do
      before { generate_questions(15) }
      before { post :create }

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
  end

  describe "#answer" do
    context "user sign_in" do
      before { sign_in user }

      context "user answers the question correct" do
        before { put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key } }

        it "return game no finished" do
          expect(game.finished?).to be false
        end

        it "return current_level > 0" do
          expect(game.current_level).to be > 0
        end

        it "correct redirect to game" do
          expect(response).to redirect_to(game_path(game))
        end

        it "return flash empty" do
          expect(flash.empty?).to be true
        end
      end

      context "user answers the question no correct" do
        before { put :answer, params: { id: game_w_questions.id, letter: %w[a b c d]
                                                                           .grep_v(game_w_questions.current_game_question.correct_answer_key).sample } }

        it "return game finished" do
          expect(game.finished?).to be true
        end

        it "return current_level == 0" do
          expect(game.current_level).to be 0
        end

        it "correct redirect to user" do
          expect(response).to redirect_to(user_path(user))
        end

        it "return flash no empty" do
          expect(flash.empty?).to be false
        end
      end
    end

    context "user not sign_in" do
      before { put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key } }
      it "return correct html status" do
        expect(response.status).not_to eq(200)
      end

      it "correct redirect to new_user" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "renders alert in flash" do
        expect(flash[:alert]).to be
      end
    end
  end

  describe "#take_money" do
    context "user sign_in" do
      before { sign_in user }

      context "game isnt finished" do
        it "return correct params, redirect and flash" do
          game_w_questions.update_attribute(:current_level, 2)

          put :take_money, params: { id: game_w_questions.id }

          expect(game.finished?).to be_truthy
          expect(game.prize).to eq(200)

          user.reload
          expect(user.balance).to eq(200)
          expect(response).to redirect_to(user_path(user))
          expect(flash[:warning]).to be
        end
      end
    end

    context "user not sign_in" do
      before { put :take_money, params: { id: game_w_questions.id } }
      it "return correct html status" do
        expect(response.status).not_to eq(200)
      end

      it "correct redirect to new_user" do
        expect(response).to redirect_to(new_user_session_path)
      end

      it "renders alert in flash" do
        expect(flash[:alert]).to be
      end
    end
  end
end
