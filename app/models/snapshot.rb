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
  include PublicActivity::Model
  tracked owner: ->(controller, _model) { controller && controller.current_user }

  belongs_to :user, required: true, class_name: 'User', foreign_key: 'user_id', touch: true
  after_create :track_creation
  after_destroy :track_deletion

  validates :height_cm, presence: true, numericality: { less_than: 228.6, greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { less_than: 226.8, greater_than: 0 }

  validates :activity_level, presence: true, inclusion: { in: %w[
    sedentary
    lightly_active
    moderately_active
    very_active
    super_active
  ] }
  validates :goal_weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :calorie_deficit_or_surplus_per_day, presence: true, numericality: { less_than: 10_000 }
  validate :calorie_deficit_or_surplus_must_be_positive_if_weight_less_than_goal_weight
  validate :calorie_deficit_or_surplus_per_day_must_be_negative_if_weight_greater_than_goal_weight
  validate :calorie_deficit_within_bmr_range

  ACTIVITY_FACTORS = {
    'sedentary' => 1.2,
    'lightly_active' => 1.375,
    'moderately_active' => 1.55,
    'very_active' => 1.725,
    'super_active' => 1.9
  }.freeze

  def predicted_time
    if weight_kg.nil?
      errors.add(:weight_kg, 'cannot be nil')
      return
    end
  
    if goal_weight_kg.nil?
      errors.add(:goal_weight_kg, 'cannot be nil')
      return
    end
  
    if calorie_deficit_or_surplus_per_day.nil?
      errors.add(:calorie_deficit_or_surplus_per_day, 'cannot be nil')
      return
    end
  
    weight_difference = (weight_kg - goal_weight_kg).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7 / 7700.0
  
    return "Indeterminate time" if calorie_difference_per_week.zero?
  
    time_in_weeks = (weight_difference / calorie_difference_per_week).ceil
  
    # Extract years
    years = time_in_weeks / 52
    remaining_weeks = time_in_weeks % 52
  
    # Extract months using a more precise conversion
    months = (remaining_weeks / 4.345)
    remaining_weeks = (remaining_weeks % 4.345) # Ensure we only keep the leftover weeks
  
    # Convert any leftover weeks into days (max 6 days)
    days = ((remaining_weeks % 1) * 7)
    remaining_weeks = remaining_weeks.to_f
  
    # Prevent cases where days roll over into a full week
    if days >= 7
      remaining_weeks += 1
      days -= 7
    end
  
    # Formatting output properly
    parts = []
    parts << "#{years.round(0)} #{'year'.pluralize(years)}" if years.positive?
    parts << "#{months.round(0)} #{'month'.pluralize(months)}" if months.positive?
    parts << "#{remaining_weeks.round(0)} #{'week'.pluralize(remaining_weeks)}" if remaining_weeks.positive?
    parts << "#{days.round(0)} #{'day'.pluralize(days)}" if days.positive?
  
    return "0 days" if parts.empty?
  
    parts.join(', ').sub(/,([^,]*)$/, ' and\1') # Proper formatting for last part
  end
  
  
  def bmr
    dob = user.dob
    now = Time.now.utc.to_date
    age = now.year - dob.year - (now.month > dob.month || (now.month == dob.month && now.day >= dob.day) ? 0 : 1)
    if user.gender == 'male'

      10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    else
      10 * weight_kg + 6.25 * height_cm - 5 * age - 161
    end
  end

  def tdee
    bmr * ACTIVITY_FACTORS[activity_level]
  end

  def ideal_body_weight_max
    base_weight = if user.gender == 'male'
                    50 + 2.3 * ((height_cm - 152.4) / 2.54)
                  else
                    45.5 + 2.3 * ((height_cm - 152.4) / 2.54)
                  end
    max_weight_kg = base_weight + (base_weight * 0.1)
    max_weight_kg * 2.20462
  end

  def ideal_body_weight_min
    base_weight = if user.gender == 'male'
                    50 + 2.3 * ((height_cm - 152.4) / 2.54)
                  else
                    45.5 + 2.3 * ((height_cm - 152.4) / 2.54)
                  end
    min_weight_kg = base_weight - (base_weight * 0.1)
    min_weight_kg * 2.20462
  end

  # use boer equation to calculate lean body mass
  def lean_body_mass
    lean_mass = if user.gender == 'male'
                  (0.407 * weight_kg) + (0.267 * height_cm) - 19.2
                else
                  (0.252 * weight_kg) + (0.473 * height_cm) - 48.3
                end
    lean_mass * 2.20462
  end

  def body_mass_index
    weight_kg / (height_cm / 100.0)**2
  end

  def bmi_category
    bmi = body_mass_index
    if bmi < 18.5
      'Underweight'
    elsif bmi >= 18.5 && bmi < 24.9
      'Normal weight'
    elsif bmi >= 25 && bmi < 29.9
      'Overweight'
    else
      'Obese'
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

  private

  def calorie_deficit_within_bmr_range
    return unless calorie_deficit_or_surplus_per_day.present? && bmr.present?
    return unless calorie_deficit_or_surplus_per_day.negative? && calorie_deficit_or_surplus_per_day.abs > bmr

    errors.add(:calorie_deficit_or_surplus_per_day,
               'must be less than the basal metabolic rate (BMR) when in deficit')
  end

  def calorie_deficit_or_surplus_must_be_positive_if_weight_less_than_goal_weight
    return unless weight_kg.present? && goal_weight_kg.present? && calorie_deficit_or_surplus_per_day.present?
    return unless weight_kg < goal_weight_kg && calorie_deficit_or_surplus_per_day <= 0

    errors.add(:calorie_deficit_or_surplus_per_day, 'must be positive in order to gain weight')
  end

  def calorie_deficit_or_surplus_per_day_must_be_negative_if_weight_greater_than_goal_weight
    return unless weight_kg.present? && goal_weight_kg.present? && calorie_deficit_or_surplus_per_day.present?
    return unless weight_kg > goal_weight_kg && calorie_deficit_or_surplus_per_day >= 0

    errors.add(:calorie_deficit_or_surplus_per_day, 'must be negative in order to lose weight')
  end

  def track_creation
    PublicActivity::Activity.create(
      key: 'snapshot.created',
      owner: user,
      trackable: self
    )
  end

  def track_deletion
    PublicActivity::Activity.create(
      key: 'snapshot.deleted',
      owner: user,
      trackable: self
    )
  end

  def dob
    user.dob
  end
end
