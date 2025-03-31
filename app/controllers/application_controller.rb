# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include DeviseParameterSanitizer
  before_action :authenticate_user!, except: [:home]
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :track_action
  include Applicable
end
