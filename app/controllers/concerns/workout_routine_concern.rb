# frozen_string_literal: true

module WorkoutRoutineConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_workout_routine, only: %i[show edit update destroy]
  end

  def index
    @workout_routines = current_user.workout_routines
  end

  def show
    @workout_routine = WorkoutRoutine.find(params[:id])
    @workout_routine.acute_load = @workout_routine.calculate_acute_load
    @workout_routine.chronic_load = @workout_routine.calculate_chronic_load

    @workout_routine.save
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

  def edit; end

  def update
    if @workout_routine.update(workout_routine_params)
      @workout_routine.acute_load = @workout_routine.calculate_acute_load
      @workout_routine.chronic_load = @workout_routine.calculate_chronic_load
      @workout_routine.burnout_risk_score = @workout_routine.calculate_burnout_risk_score
      @workout_routine.save
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

  def workout_routine_params
    params.require(:workout_routine).permit(:name, :description, :mood, :soreness, :sleep_quality, :acute_load,
                                            :chronic_load, :burnout_risk_score)
  end

  def set_workout_routine
    @workout_routine = current_user.workout_routines.find(params[:id])
  end
end
