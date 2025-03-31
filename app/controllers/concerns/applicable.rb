module Applicable
  extend ActiveSupport::Concern

  def home
    @breadcrumbs = [
      {content: "Welcome", href: root_path}
    ]
    render 'layouts/home'
  end

  def after_sign_in_path_for(resource)
    user_path(resource) # Redirect to the profile page
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[height_cm weight_kg gender activity_level dob])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[height_cm weight_kg gender activity_level dob])
  end

  def track_action
    ahoy.track "Processed #{controller_name}##{action_name}", request.filtered_parameters
  end
end
