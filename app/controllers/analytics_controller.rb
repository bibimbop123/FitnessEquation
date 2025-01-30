# frozen_string_literal: true

class AnalyticsController < ApplicationController
  def index
    ahoy.track 'Viewed Analytics Page'
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
    @predicted_time_data = @snapshots.map do |snapshot|
      [(snapshot.weight_kg / 0.453592).round(2), snapshot.predicted_time_weeks.abs]
    end.compact
    @activity_level_data = @snapshots.group(:activity_level).count
    @predicted_time_calorie_data = @snapshots.map do |snapshot|
      [snapshot.predicted_time_weeks.abs, snapshot.calorie_deficit_or_surplus_per_day]
    end
  end

  def ahoyanalytics
    @ahoy_events = Ahoy::Event.includes(:user).all
    @ahoy_visits = Ahoy::Visit.all

    # Chartkick data for visits
    @visits_by_day = @ahoy_visits.group_by_day(:started_at).count
    @visits_by_week = @ahoy_visits.group_by_week(:started_at).count
    @visits_by_month = @ahoy_visits.group_by_month(:started_at).count
  end
end
