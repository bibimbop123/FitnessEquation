# frozen_string_literal: true

class OneRepMaxesController < ApplicationController # rubocop:disable Style/Documentation
  include SetOneRepMaxConcern
  before_action :authenticate_user!


end
