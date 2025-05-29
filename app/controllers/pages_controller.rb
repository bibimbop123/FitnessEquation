class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:donate]

  def donate
    # Donation page logic
  end
end
