# frozen_string_literal: true

class PwaController < ApplicationController
  skip_before_action :authenticate_user!
  def manifest; end
end
