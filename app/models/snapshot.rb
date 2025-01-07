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
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"

  validates :height_cm, presence: true, numericality: { greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  
  validates :activity_level, presence: true, inclusion: { in: [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'super_active'
  ] }
  validates :goal_weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :predicted_time_weeks, presence: true
  validates :calorie_deficit_or_surplus_per_day, presence: true
  ACTIVITY_FACTORS = {
    "sedentary" => 1.2,
    "lightly_active" => 1.375,
    "moderately_active" => 1.55,
    "very_active" => 1.725,
    "super_active" => 1.9
  }.freeze

  def bmr
    if user.gender == "male"

      dob = user.dob
      now = Time.now.utc.to_date
      age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)

      10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    else
      dob = user.dob
      now = Time.now.utc.to_date
      age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
      10 * weight_kg + 6.25 * height_cm - 5 * age - 161
    end
  end

  def tdee
    bmr * ACTIVITY_FACTORS[activity_level]
  end


  def predicted_time_weeks
    weight_difference = (weight_kg - goal_weight_kg).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7 / 7700.0
    (weight_difference / calorie_difference_per_week).ceil
  end
end
