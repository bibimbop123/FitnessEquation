module WorkoutRoutine::Chartkickable
  extend ActiveSupport::Concern

  included do
    # TODO
    @workout_routines_data = @workout_routines.joins(:exercises).group_by_day('workout_routines.created_at').sum('exercises.sets * exercises.reps * exercises.weight')
  end
end
