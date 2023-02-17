class RailsAdminAbstractController < ActionController::Base
  around_action :switch_locale

  private

  def switch_locale(&action)
    I18n.with_locale(:en, &action) # or anything you like
  end
end
