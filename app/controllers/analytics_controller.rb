# frozen_string_literal: true

class AnalyticsController < ApplicationController
  def index
    ahoy.track 'Viewed Analytics Page'

    @snapshots = Snapshot.where(user: current_user)

    @workout_routines = WorkoutRoutine.where(user: current_user)
    @total_volume_lifted = @workout_routines.joins(:exercises).sum('exercises.sets * exercises.reps * exercises.weight')
    @one_rep_maxes = OneRepMax.where(user: current_user)
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
