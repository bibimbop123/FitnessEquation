class WorkoutRoutinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_workout_routine, only: %i[show edit update destroy]

  def index
    @workout_routines = current_user.workout_routines
  end

  def show
  end

  def new
    @workout_routine = current_user.workout_routines.new
  end

  def create
    @workout_routine = current_user.workout_routines.new(workout_routine_params)
    if @workout_routine.save
      redirect_to @workout_routine, notice: 'Workout routine was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @workout_routine.update(workout_routine_params)
      redirect_to @workout_routine, notice: 'Workout routine was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @workout_routine.destroy
    redirect_to workout_routines_url, notice: 'Workout routine was successfully destroyed.'
  end

  private

  def set_workout_routine
    @workout_routine = current_user.workout_routines.find(params[:id])
  end

  def workout_routine_params
    params.require(:workout_routine).permit(:name, :description)
  end
end
