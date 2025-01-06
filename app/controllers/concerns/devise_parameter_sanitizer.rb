# app/controllers/concerns/devise_parameter_sanitizer.rb
module DeviseParameterSanitizer
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters, if: :devise_controller?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:dob, :gender])
    devise_parameter_sanitizer.permit(:account_update, keys: [:dob, :gender])
  end
end
