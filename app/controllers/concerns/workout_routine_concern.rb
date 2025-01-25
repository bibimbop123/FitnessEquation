module WorkoutRoutineConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_workout_routine, only: %i[show edit update destroy]
  end

  private

  def set_workout_routine
    @workout_routine = current_user.workout_routines.find(params[:id])
  end
end
