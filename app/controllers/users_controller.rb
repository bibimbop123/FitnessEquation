# frozen_string_literal: true

class UsersController < ApplicationController
  include Userable
  before_action :authenticate_user!
end
