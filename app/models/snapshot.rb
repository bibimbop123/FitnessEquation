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

  validates :height_cm, presence: { message: "cannot be nil" }, numericality: { less_than: 228.6, greater_than: 0 }
  validates :weight_kg, presence: { message: "cannot be nil" }, numericality: { less_than: 226.8, greater_than: 0 }
  
  validates :activity_level, presence: { message: "cannot be nil" }, inclusion: { in: [
    'sedentary',
    'lightly_active',
    'moderately_active',
    'very_active',
    'super_active'
  ] }
  validates :goal_weight_kg, presence: { message: "cannot be nil" }, numericality: { greater_than: 0 }
  validates :predicted_time_weeks, presence: { message: "cannot be nil" }
  validates :calorie_deficit_or_surplus_per_day, presence: { message: "cannot be nil" }, numericality: { less_than: 10_000, greater_than: -10_000 }
  validate :calorie_deficit_or_surplus_must_be_positive_if_weight_less_than_goal_weight
  validate :calorie_deficit_or_surplus_per_day_must_be_negative_if_weight_greater_than_goal_weight
  validate :check_for_nil_values

  ACTIVITY_FACTORS = {
    "sedentary" => 1.2,
    "lightly_active" => 1.375,
    "moderately_active" => 1.55,
    "very_active" => 1.725,
    "super_active" => 1.9
  }.freeze

  def predicted_time_weeks
    if weight_kg.nil?
      errors.add(:weight_kg, "cannot be nil")
      return
    end
  
    if goal_weight_kg.nil?
      errors.add(:goal_weight_kg, "cannot be nil")
      return
    end
  
    if calorie_deficit_or_surplus_per_day.nil?
      errors.add(:calorie_deficit_or_surplus_per_day, "cannot be nil")
      return
    end
  
    weight_difference = (weight_kg - goal_weight_kg).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7 / 7700.0
    (weight_difference / calorie_difference_per_week).ceil
  end
  
  def check_for_nil_values
    errors.add(:height_cm, "cannot be nil") if height_cm.nil?
    errors.add(:weight_kg, "cannot be nil") if weight_kg.nil?
    errors.add(:activity_level, "cannot be nil") if activity_level.nil?
    errors.add(:goal_weight_kg, "cannot be nil") if goal_weight_kg.nil?
    errors.add(:predicted_time_weeks, "cannot be nil") if predicted_time_weeks.nil?
    errors.add(:calorie_deficit_or_surplus_per_day, "cannot be nil") if calorie_deficit_or_surplus_per_day.nil?
  end
  
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

  def ideal_body_weight_max
    if user.gender == "male"
      base_weight = 50 + 2.3 * ((height_cm - 152.4) / 2.54)
      max_weight_kg = base_weight + (base_weight * 0.1) # Add 10% for maximum
      max_weight_kg * 2.20462 # Convert to lbs
    else
      base_weight = 45.5 + 2.3 * ((height_cm - 152.4) / 2.54)
      max_weight_kg = base_weight + (base_weight * 0.1) # Add 10% for maximum
      max_weight_kg * 2.20462 # Convert to lbs
    end
  end
  
  def ideal_body_weight_min
    if user.gender == "male"
      base_weight = 50 + 2.3 * ((height_cm - 152.4) / 2.54)
      min_weight_kg = base_weight - (base_weight * 0.1) # Subtract 10% for minimum
      min_weight_kg * 2.20462 # Convert to lbs
    else
      base_weight = 45.5 + 2.3 * ((height_cm - 152.4) / 2.54)
      min_weight_kg = base_weight - (base_weight * 0.1) # Subtract 10% for minimum
      min_weight_kg * 2.20462 # Convert to lbs
    end
  end
  #use boer equation to calculate lean body mass
  def lean_body_mass
    if user.gender == "male"
      lean_mass = (0.407 * weight_kg) + (0.267 * height_cm) - 19.2
      lean_mass * 2.20462
    else
      lean_mass = (0.252 * weight_kg) + (0.473 * height_cm) - 48.3
      lean_mass * 2.20462
    end
  end

  def body_mass_index
    weight_kg / (height_cm / 100.0) ** 2
  end

  def bmi_category
    bmi = body_mass_index
    case
    when bmi < 18.5
      "Underweight"
    when bmi >= 18.5 && bmi < 24.9
      "Normal weight"
    when bmi >= 25 && bmi < 29.9
      "Overweight"
    else
      "Obese"
    end
  end
  
  def recommended_protein_intake_per_day(activity_level)
    case activity_level
    when :sedentary
      weight_kg * 0.8
    when :moderate_exercise, :endurance_athlete
      weight_kg * 1.2
    when :strength_training
      weight_kg * 1.6
    when :older_adult
      weight_kg * 1.0
    when :weight_loss
      weight_kg * 2.0
    else
      weight_kg * 0.8
    end
  end

  def calorie_deficit_or_surplus_must_be_positive_if_weight_less_than_goal_weight
    if weight_kg.present? && goal_weight_kg.present? && calorie_deficit_or_surplus_per_day.present?
      if weight_kg < goal_weight_kg && calorie_deficit_or_surplus_per_day <= 0
        errors.add(:calorie_deficit_or_surplus_per_day, "must be positive in order to gain weight")
      end
    end
  end
  
  def calorie_deficit_or_surplus_per_day_must_be_negative_if_weight_greater_than_goal_weight
    if weight_kg.present? && goal_weight_kg.present? && calorie_deficit_or_surplus_per_day.present?
      if weight_kg > goal_weight_kg && calorie_deficit_or_surplus_per_day >= 0
        errors.add(:calorie_deficit_or_surplus_per_day, "must be negative in order to lose weight")
      end
    end
  end
end
