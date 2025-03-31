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
end
