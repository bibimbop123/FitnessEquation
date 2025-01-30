# frozen_string_literal: true

class ExercisesController < ApplicationController
  before_action :set_workout_routine
  before_action :set_exercise, only: %i[show edit update destroy]

  def index
    @exercises = @workout_routine.exercises
    render '/exercises/index'
  end

  def show; end

  def new
    @exercise = @workout_routine.exercises.new
  end

  def create
    @exercise = @workout_routine.exercises.new(exercise_params)
    if @exercise.save
      redirect_to @workout_routine, notice: 'Exercise was successfully created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @exercise.update(exercise_params)
      redirect_to [@workout_routine, @exercise], notice: 'Exercise was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @exercise.destroy
    redirect_to workout_routine_exercises_path(@workout_routine), notice: 'Exercise was successfully destroyed.'
  end

  private

  def set_workout_routine
    @workout_routine = current_user.workout_routines.find(params[:workout_routine_id])
  end

  def set_exercise
    @exercise = @workout_routine.exercises.find(params[:id])
  end

  def exercise_params
    params.require(:exercise).permit(:name, :weight, :reps, :sets, :volume)
  end
end
