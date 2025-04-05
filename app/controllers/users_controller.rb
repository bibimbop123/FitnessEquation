# frozen_string_literal: true

class UsersController < ApplicationController
  include Userable
  before_action :authenticate_user!
  skip_before_action :authenticate_user!, only: :manifest

  def manifest
    # Serve the manifest.json file
    render file: '../views/pwa/manifest.json.erb', # Adjust the path as necessary
           content_type: 'application/json',
           layout: false # Ensures no layout is applied to the manifest
  rescue StandardError => e
    # Handle the case where the file cannot be found or read
    # You can log the error or render a default manifest
    # Rails.logger.error "Failed to serve manifest: #{e.message}"
    render json: { error: 'Manifest not found' }, status: :not_found
  end
end
