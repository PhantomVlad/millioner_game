require "rails_helper"

RSpec.feature "USER view other profile", type: :feature do
  let(:user1) { FactoryBot.create :user, name: "Влад" }
  let(:user2) { FactoryBot.create :user }

  let!(:game1) { FactoryBot.create :game_with_questions, user: user1, current_level: 0, prize: 0, is_failed: true,
                                   created_at: "2023-02-25 16:56:00 +0300".to_datetime,
                                   finished_at: "2023-02-25 16:58:00 +0300".to_datetime }
  let!(:game2) { FactoryBot.create :game_with_questions, user: user1, current_level: 15, prize: 1000000,
                                   created_at: "2023-02-25 16:46:00 +0300".to_datetime,
                                   finished_at: "2023-02-25 16:56:00 +0300".to_datetime }

  before do
    login_as user2
  end

  scenario "success" do
    visit "/users/2"

    expect(page).to have_content("Влад")
    expect(page).to have_content("проигрыш")
    expect(page).to have_content("25 февр., 16:56")
    expect(page).to have_content("победа")
    expect(page).to have_content("25 февр., 16:46")
    expect(page).to have_content("15")
    expect(page).to have_content("1 000 000")
    expect(page).to have_no_link("Сменить имя и пароль")
  end
end
