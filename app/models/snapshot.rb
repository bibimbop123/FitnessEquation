# == Schema Information
#
# Table name: snapshots
#
#  id                      :bigint           not null, primary key
#  activity_level          :string
#  calorie_deficit_per_day :integer
#  dob                     :date
#  gender                  :string
#  goal_weight_kg          :float
#  height_cm               :float
#  predicted_time_weeks    :integer
#  weight_kg               :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
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
  validates :calorie_deficit_per_day, presence: true, numericality: { greater_than: 0 }
  validates :gender, inclusion: { in: ['male', 'female'], allow_nil: true }
  validates :age, numericality: { greater_than: 0, allow_nil: true }


  def bmr
  
    # Use the Mifflin-St Jeor Equation
  
    # Use the Mifflin-St Jeor Equation
    if self.gender.downcase == "male"
      bmr_value = (10 * weight_kg) + (6.25 * height_cm) - (5 * user.age) + 5
    elsif self.gender.downcase == "female"
      bmr_value = (10 * weight_kg) + (6.25 * height_cm) - (5 * user.age) - 161
    else
      raise "Unsupported gender for BMR calculation"
    end
  
    return bmr_value
  end

  def tdee
    # Ensure the BMR can be calculated
    raise "BMR calculation failed" unless bmr

    # Define activity multipliers
    activity_multipliers = {
      'Sedentary (Little to no physical activity)' => 1.2,
      'Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)' => 1.375,
      'Moderately Active (Moderate exercise or sports 3-5 days per week)' => 1.55,
      'Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)' => 1.725,
      'Super Active (Very intense exercise, physical training twice daily, or an extremely physically demanding job)' => 1.9
    }

    # Get the activity multiplier
    activity_multiplier = activity_multipliers[activity_level]

    # Raise an error if the activity level is invalid
    raise "Invalid activity level for TDEE calculation" unless activity_multiplier

    # Calculate TDEE
    (bmr * activity_multiplier).round(2)
  end

  def daily_calories
  end
end
