module Snapable
  extend ActiveSupport::Concern

  included do
    validates :activity_level, presence: true, inclusion: { in: ACTIVITY_FACTOR.keys.map(&:to_s) }
  end

  ACTIVITY_FACTOR = { 
    sedentary: {
      description: 'Sedentary (Little to no physical activity)',
      multiplier: 1.2
    },
    lightly_active: {
      description: 'Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)',
      multiplier: 1.375
    },
    moderately_active: {
      description: 'Moderately Active (Moderate exercise or sports 3-5 days per week)',
      multiplier: 1.55
    },
    very_active: {
      description: 'Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)',
      multiplier: 1.725
    },
    super_active: {
      description: 'Super Active (Very intense exercise physical training twice daily or an extremely physically demanding job)',
      multiplier: 1.9
    }
  }.freeze

  PROTEIN_FACTORS = {
    'Sedentary (Little to no physical activity)' => 0.8,
    'Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)' => 1.0,
    'Moderately Active (Moderate exercise or sports 3-5 days per week)' => 1.2,
    'Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)' => 1.4,
    'Super Active (Very intense exercise physical training twice daily or an extremely physically demanding job)' => 1.6
  }.freeze

  MIN_INTAKE = 250
  MAX_INTAKE = 4000

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
  
    # Convert kg to lbs if needed
    weight_lb = weight_kg * 2.20462
    goal_weight_lb = goal_weight_kg * 2.20462
  
    weight_difference = (weight_lb - goal_weight_lb).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7
  
    return 'Indeterminate time' if calorie_difference_per_week.zero?
  
    time_in_weeks = (weight_difference * 3500 / calorie_difference_per_week).ceil
  
    years = time_in_weeks / 52
    remaining_weeks = time_in_weeks % 52
  
    months = (remaining_weeks / 4.345)
    remaining_weeks = (remaining_weeks % 4.345)
  
    days = ((remaining_weeks % 1) * 7)
    remaining_weeks = remaining_weeks.to_f
  
    if days >= 7
      remaining_weeks += 1
      days -= 7
    end
  
    parts = []
    parts << "#{years.round(0)} #{'year'.pluralize(years)}" if years.positive?
    parts << "#{months.round(0)} #{'month'.pluralize(months)}" if months.positive?
    parts << "#{remaining_weeks.round(0)} #{'week'.pluralize(remaining_weeks)}" if remaining_weeks.positive?
    parts << "#{days.round(0)} #{'day'.pluralize(days)}" if days.positive?
  
    return '0 days' if parts.empty?
  
    parts.join(', ').sub(/,([^,]*)$/, ', and\1')
  end
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
  
    # Convert kg to lbs if needed
    weight_lb = weight_kg * 2.20462
    goal_weight_lb = goal_weight_kg * 2.20462
  
    weight_difference = (weight_lb - goal_weight_lb).abs
    calorie_difference_per_week = calorie_deficit_or_surplus_per_day * 7
  
    return 'Indeterminate time' if calorie_difference_per_week.zero?
  
    time_in_weeks = (weight_difference * 3500 / calorie_difference_per_week.abs).ceil
  
    years = time_in_weeks / 52
    remaining_weeks = time_in_weeks % 52
  
    months = (remaining_weeks / 4.345)
    remaining_weeks = (remaining_weeks % 4.345)
  
    days = ((remaining_weeks % 1) * 7)
    remaining_weeks = remaining_weeks.to_f
  
    if days >= 7
      remaining_weeks += 1
      days -= 7
    end
  
    parts = []
    parts << "#{years.round(0)} #{'year'.pluralize(years)}" if years.positive?
    parts << "#{months.round(0)} #{'month'.pluralize(months)}" if months.positive?
    parts << "#{remaining_weeks.round(0)} #{'week'.pluralize(remaining_weeks)}" if remaining_weeks.positive?
    parts << "#{days.round(0)} #{'day'.pluralize(days)}" if days.positive?
  
    return '0 days' if parts.empty?
  
    parts.join(', ').sub(/,([^,]*)$/, ', and\1')
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
    # return nil unless bmr.present? && ACTIVITY_FACTOR[activity_level].present?

    # bmr * ACTIVITY_FACTOR[activity_level][:multiplier]
    ACTIVITY_FACTOR[activity_level.to_sym][:multiplier] * bmr
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

  def lean_body_mass
    if weight_kg.nil? || height_cm.nil?
      errors.add(:base, 'Weight and height cannot be nil when calculating lean body mass')
      return nil
    end

    bmi = body_mass_index
    if bmi.nil? || bmi <= 0
      errors.add(:base, 'BMI must be greater than zero to calculate lean body mass')
      return nil
    end

    # Apply Janmahasatian formula based on gender
    denominator = user.gender == 'male' ? (6680 + (216 * bmi)) : (8780 + (244 * bmi))

    lbm_kg = (9270 * weight_kg) / denominator
    lbm_lbs = lbm_kg * 2.20462

    lbm_lbs.round(2)
  rescue StandardError => e
    Rails.logger.error "Error calculating lean body mass: #{e.message}" if Rails.env.development?
    errors.add(:base, 'An error occurred while calculating lean body mass')
    nil
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
      weight_kg * PROTEIN_FACTORS['Sedentary (Little to no physical activity)']
    when :lightly_active
      weight_kg * PROTEIN_FACTORS['Lightly Active (Light exercise or sports 1-3 days per week or moderate physical activity)']
    when :moderately_active
      weight_kg * PROTEIN_FACTORS['Moderately Active (Moderate exercise or sports 3-5 days per week)']
    when :very_active
      weight_kg * PROTEIN_FACTORS['Very Active (Hard exercise or sports 6-7 days per week or a physically demanding job)']
    when :super_active
      weight_kg * PROTEIN_FACTORS['Super Active (Very intense exercise physical training twice daily or an extremely physically demanding job)']
    else
      weight_kg * PROTEIN_FACTORS['Sedentary (Little to no physical activity)']  # Default case
    end
  end

  def recommended_creatine_intake_per_day_loading_phase
    if weight_kg.nil?
      errors.add(:weight_kg, 'cannot be nil when calculating creatine intake')
      return nil
    end

    # Standard loading phase: 0.3g per kg of bodyweight per day
    intake = (weight_kg * 0.3).round(2)
    [intake, 25.0].min # rounding to 2 decimal places for clarity
  end

  def recommended_creatine_intake_per_day_maintenance_phase
    if weight_kg.nil?
      errors.add(:weight_kg, 'cannot be nil when calculating creatine intake')
      return nil
    end

    # Standard maintenance dose: 0.03g per kg of bodyweight
    (weight_kg * 0.03).round(2)
  end

  def recommended_daily_water_intake
    return nil if weight_kg.nil?

    base_multiplier = 35 # ml per kg
    water_intake_ml = (weight_kg * base_multiplier).round(2)

    # Clamp to safety thresholds
    water_intake_ml = water_intake_ml.clamp(MIN_INTAKE, MAX_INTAKE)

    # Convert ml to liters (rounded to 2 decimals)
    (water_intake_ml / 1000.0).round(2)
  rescue StandardError => e
    Rails.logger.error "Error calculating recommended daily water intake: #{e.message}" if Rails.env.development?
    errors.add(:base, 'An error occurred while calculating recommended daily water intake')
    nil
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

  def virtual_params
    {
      predicted_time_weeks: predicted_time,
      bmr: bmr,
      tdee: tdee,
      ideal_body_weight_max: ideal_body_weight_max,
      ideal_body_weight_min: ideal_body_weight_min,
      lean_body_mass: lean_body_mass,
      body_mass_index: body_mass_index,
      bmi_category: bmi_category,
      recommended_protein_intake_per_day: recommended_protein_intake_per_day(activity_level)
    }
  end
end
