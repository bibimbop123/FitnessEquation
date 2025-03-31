# frozen_string_literal: true

class ExercisesController < ApplicationController
  include Exercisable

  before_action :set_workout_routine
  before_action :set_exercise, only: %i[show edit update destroy]

end
