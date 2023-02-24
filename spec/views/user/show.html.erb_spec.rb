require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  let(:user) { create(:user, name: "Vlad", balance: 0) }

  context "user sign in" do
    before do
      sign_in user
      assign(:games, [stub_template('users/_game.html.erb' => 'User game goes here')])
      assign(:user, user)
      render
    end

    it 'user view nickname' do
      expect(rendered).to match 'Vlad'
    end

    it 'user view buttom edit password' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'user view status game' do
      expect(rendered).to match 'User game goes here'
    end
  end

  context "other user view buttom edit password" do
    before do
      assign(:user, user)

      render
    end

    it 'user dont view button edit password' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
