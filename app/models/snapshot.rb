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
#
class Snapshot < ApplicationRecord
  belongs_to :user, required: true, class_name: "User", foreign_key: "user_id"

  validates :height_cm, presence: true, numericality: { greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  
  validates :activity_level, presence: true, inclusion: { in: [
    'Sedentary (Little to no physical activity)',
    'Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)',
    'Moderately Active (Moderate exercise or sports 3-5 days per week)',
    'Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)',
    'Super Active (Very intense exercise, physical training twice daily, or an extremely physically demanding job)'
  ] }
  validates :goal_weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :predicted_time_weeks, presence: true, numericality: { greater_than: 0 }
  validates :calorie_deficit_or_surplus_per_day, presence: true, numericality: { greater_than: 0 }
  ACTIVITY_FACTORS = {
    "sedentary" => 1.2,
    "lightly_active" => 1.375,
    "moderately_active" => 1.55,
    "very_active" => 1.725,
    "extra_active" => 1.9
  }.freeze

  def bmr
    if user.gender == "male"

      dob = Date.parse(user.dob)
      now = Time.now.utc.to_date
      age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)

      10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    else
      10 * weight_kg + 6.25 * height_cm - 5 * age - 161
    end
  end

  def tdee
    bmr * ACTIVITY_FACTORS[activity_level]
  end

  def age
    ((Time.zone.now - user.birthday.to_time) / 1.year.seconds).floor
  end

  def predicted_time_weeks
    weight_difference = (weight_kg - goal_weight_kg).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7 / 7700.0
    (weight_difference / calorie_difference_per_week).ceil
  end
end
