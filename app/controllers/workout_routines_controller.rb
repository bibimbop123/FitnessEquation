# frozen_string_literal: true

class WorkoutRoutinesController < ApplicationController
  include WorkoutRoutineConcern
  before_action :authenticate_user!

 
end
