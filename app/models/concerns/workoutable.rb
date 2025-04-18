# frozen_string_literal: true

module Workoutable
  extend ActiveSupport::Concern

  def total_volume
    exercises.sum(&:volume)
  end

  def track_creation
    PublicActivity::Activity.create(
      key: 'workout.created',
      owner: user,
      trackable: self
    )
  end

  def track_deletion
    PublicActivity::Activity.create(
      key: 'workout.deleted',
      owner: user,
      trackable: self
    )
  end

  # Calculate Acute Load (last 7 days)
  def calculate_acute_load
    Exercise.joins(:workout_routine)
            .where(workout_routines: { user_id: id })
            .where('exercises.created_at >= ?', 7.days.ago)
            .sum('reps * sets * weight')
  end

  def calculate_chronic_load
    total_load = Exercise.joins(:workout_routine)
                         .where(workout_routines: { user_id: id })
                         .where('exercises.created_at >= ?', 4.weeks.ago)
                         .sum('reps * sets * weight')

    (total_load / 4.0).round(2)
  end

  # Calculate ACWR
  def acwr
    return 0 if chronic_load.zero?

    acute_load.to_f / chronic_load
  end

  # Interpret ACWR status
  def acwr_status
    total_workouts = exercises.where('created_at >= ?', 4.weeks.ago).count
    return 'Insufficient Data (Need at least 4 weeks of workouts)' if total_workouts < 4

    if acwr > 1.5
      'High Risk of Burnout'
    elsif acwr.between?(0.8, 1.3)
      'Optimal Training Zone'
    elsif acwr < 0.8
      'Undertraining'
    else
      'Moderate Risk'
    end
  end

  def tsb
    chronic_load - acute_load
  end

  def calculate_burnout_risk_score
    # Use the model's attributes directly, with fallback default values
    mood_value = mood || 5
    sleep_quality_value = sleep_quality || 5
    soreness_value = soreness || 5
    acwr || 0

    # Calculate the burnout risk score
    100 - (acwr * 100) + (mood_value * 10) + (sleep_quality_value * 10) - (soreness_value * 10)
  end
end
