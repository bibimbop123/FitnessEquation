# frozen_string_literal: true

class SnapshotProcessor
  def initialize(snapshot, params = {})
    @snapshot = snapshot
    @params = params
  end

  def call
    puts "Processing snapshot with params: #{@params.inspect}"

    convert_weight if @params[:weightLbs]
    convert_height if @params[:heightFeet] && @params[:heightInches]
    convert_goal_weight if @params[:goal_weight_lbs]
    assign_other_attributes
  end

  def convert_weight
    weight_lbs = @params[:weightLbs].to_f
    @snapshot.weight_kg = (weight_lbs * 0.453592).round(2)
  end

  def convert_height
    height_feet = @params[:heightFeet].to_i
    height_inches = @params[:heightInches].to_f
    total_height_inches = (height_feet * 12) + height_inches
    @snapshot.height_cm = (total_height_inches * 2.54).round(2)
  end

  def convert_goal_weight
    goal_weight_lbs = @params[:goal_weight_lbs].to_f
    @snapshot.goal_weight_kg = (goal_weight_lbs * 0.453592).round(2)
  end

  def assign_other_attributes
    @snapshot.activity_level = @params[:activity_level] if @params[:activity_level]
    @snapshot.predicted_time_weeks = @params[:predicted_time_weeks] if @params[:predicted_time_weeks]
    return unless @params[:calorie_deficit_or_surplus_per_day]

    @snapshot.calorie_deficit_or_surplus_per_day = @params[:calorie_deficit_or_surplus_per_day].to_s.gsub(/[^\d-]/,
                                                                                                          '').to_i
  end

  def calculate_show_values
    weight_lbs = (@snapshot.weight_kg / 0.453592).round(2)
    total_height_inches = (@snapshot.height_cm / 2.54).round(2)
    height_feet = (total_height_inches / 12).to_i
    height_inches = (total_height_inches % 12).round(2)
    goal_weight_lbs = (@snapshot.goal_weight_kg / 0.453592).round(2)

    {
      weight_lbs: weight_lbs,
      height_feet: height_feet,
      height_inches: height_inches,
      goal_weight_lbs: goal_weight_lbs
    }
  end

  def dob
    @snapshot.user.dob if @snapshot.user.present?

  end
end
