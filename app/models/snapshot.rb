# frozen_string_literal: true

# == Schema Information
#
# Table name: snapshots
#
#  id                                 :bigint           not null, primary key
#  activity_level                     :string
#  calorie_deficit_or_surplus_per_day :integer
#  goal_weight_kg                     :float
#  height_cm                          :float
#  predicted_time_weeks               :integer
#  weight_kg                          :float
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  user_id                            :bigint           not null
#
# Indexes
#
#  index_snapshots_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
class Snapshot < ApplicationRecord
  include Chartkickable
  include Snapable
  include PublicActivity::Model
  

  tracked owner: ->(controller, _model) { controller && controller.current_user }

  belongs_to :user, required: true, class_name: 'User', foreign_key: 'user_id', touch: true
  after_create :track_creation
  after_destroy :track_deletion
  validates :user, presence: true

  validates :height_cm, presence: true, numericality: { less_than: 228.6, greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { less_than: 226.8, greater_than: 0 }

  validates :goal_weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :calorie_deficit_or_surplus_per_day, presence: true, numericality: { less_than: 10_000 }
  validate :calorie_deficit_or_surplus_must_be_positive_if_weight_less_than_goal_weight
  validate :calorie_deficit_or_surplus_per_day_must_be_negative_if_weight_greater_than_goal_weight
  validate :calorie_deficit_within_bmr_range

  # TODO: move this to a concern, eg Imperialable, Convertable, etc.
  POUNDS_PER_KG = 2.2046226185
  KGS_PER_POUND = 0.453592

  def weight_lbs
    weight_kg / KGS_PER_POUND
  end

  def self.weight_expression(unit = :kg)
    case unit
    when :kg
      :weight_kg
    when :lbs
      Arel.sql("weight_kg * #{POUNDS_PER_KG}")
    else
      raise ArgumentError, "Unknown unit, #{unit}"
    end
  end
end
