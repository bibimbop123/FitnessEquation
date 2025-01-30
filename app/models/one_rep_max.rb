# frozen_string_literal: true

# == Schema Information
#
# Table name: one_rep_maxes
#
#  id                :bigint           not null, primary key
#  exercise          :string
#  one_rep_max       :float
#  relative_strength :float
#  reps              :integer
#  weight_lbs        :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  user_id           :bigint           not null
#
# Indexes
#
#  index_one_rep_maxes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OneRepMax < ApplicationRecord
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user }

  belongs_to :user, touch: true
  after_create :track_creation
  after_destroy :track_deletion

  # Validations
  validates :exercise, presence: true
  validates :weight_lbs, numericality: { greater_than: 0 }
  validates :reps, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }

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
