class ApplicationController < ActionController::Base
  include DeviseParameterSanitizer
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :track_action

  def after_sign_in_path_for(resource)
    user_path(resource) # Redirect to the profile page
  end
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:height_cm, :weight_kg, :gender, :activity_level, :dob])
    devise_parameter_sanitizer.permit(:account_update, keys: [:height_cm, :weight_kg, :gender, :activity_level, :dob])
  end

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end
 
end
