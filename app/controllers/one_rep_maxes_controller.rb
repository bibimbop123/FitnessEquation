# frozen_string_literal: true

class OneRepMaxesController < ApplicationController # rubocop:disable Style/Documentation
  include SetOneRepMaxConcern
  before_action :authenticate_user! # you are already calling this in the parent controller
end
