class AnalyticsController < ApplicationController
  def index
    @snapshots = Snapshot.where(user: current_user)

    @workout_routines = WorkoutRoutine.where(user: current_user)
    @total_volume_lifted = @workout_routines.joins(:exercises).sum('exercises.sets * exercises.reps * exercises.weight')
    @one_rep_maxes = OneRepMax.where(user: current_user)

    # Chartkick data
    @weight_data = @snapshots.map { |snapshot| [snapshot.created_at, (snapshot.weight_kg / 0.453592).round(2)] }
    @one_rep_max_data = @one_rep_maxes.map { |one_rep_max| [one_rep_max.created_at, one_rep_max.calculate_one_rep_max] }
    @one_rep_max_count_data = @one_rep_maxes.group_by_day(:created_at).count
    @snapshots_data = @snapshots.map { |snapshot| [snapshot.created_at, (snapshot.weight_kg / 0.453592).round(2)] }
    @snapshots_count_data = @snapshots.group_by_day(:created_at).count
    @workout_routines_data = @workout_routines.joins(:exercises).group_by_day('workout_routines.created_at').sum('exercises.sets * exercises.reps * exercises.weight')
    @predicted_time_data = @snapshots.map { |snapshot| [snapshot.predicted_time_weeks.abs, (snapshot.weight_kg / 0.453592).round(2)] }.compact
    @activity_level_data = @snapshots.group(:activity_level).count
    @predicted_time_calorie_data = @snapshots.map { |snapshot| [  snapshot.predicted_time_weeks.abs, snapshot.calorie_deficit_or_surplus_per_day] }
  end
end
