# frozen_string_literal: true

module Onerepmaxable
  extend ActiveSupport::Concern

  # Epley formula for 1RM
  def calculate_one_rep_max
    self.one_rep_max = (weight_lbs * (1 + reps / 30.0)).round(2)
  end

  def calculate_relative_strength
    user_weight_kg = user.snapshots.last&.weight_kg
    # convert user_weight to lbs
    user_weight = user_weight_kg.nil? ? nil : user_weight_kg * 2.20462
    self.relative_strength = if user_weight.nil?
                               nil
                             else
                               (one_rep_max / user_weight).round(2)
                             end
  end

  def relative_strength_display
    relative_strength.nil? ? 'N/A' : relative_strength
  end

  def track_creation
    PublicActivity::Activity.create(
      key: 'onerepmax.created',
      owner: user,
      trackable: self
    )
  end

  def track_deletion
    PublicActivity::Activity.create(
      key: 'onerepmax.deleted',
      owner: user,
      trackable: self
    )
  end
end
