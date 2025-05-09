# frozen_string_literal: true

# maybe just call this Deviseable for all your devise related code

# app/controllers/concerns/devise_parameter_sanitizer.rb
module DeviseParameterSanitizer
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters, if: :devise_controller?
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[dob gender])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[dob gender])
  end
end
