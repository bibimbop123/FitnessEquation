class SnapshotsController < ApplicationController
  before_action :set_snapshot, only: %i[ show edit update destroy ]

  # GET /snapshots or /snapshots.json
  def index
    @snapshots = Snapshot.where(user: current_user)
    
  end

  # GET /snapshots/1 or /snapshots/1.json
  def show
    @snapshot = Snapshot.find(params[:id])
    @weightLbs = (@snapshot.weight_kg / 0.453592).round(2)
    total_height_inches = (@snapshot.height_cm / 2.54).round(2)
    @height_feet = (total_height_inches / 12).to_i
    @height_inches = (total_height_inches % 12).round(2)
    @goal_weight_lbs = (@snapshot.goal_weight_kg / 0.453592).round(2)
  end

  # GET /snapshots/new
  def new
    @snapshot = Snapshot.new
    @snapshots = Snapshot.where(user: current_user)
  end
  # GET /snapshots/1/edit
  def edit
  end

  # POST /snapshots or /snapshots.json
  def create
    @snapshot = Snapshot.new(snapshot_params)
    @snapshot.user = current_user

    # Convert weight from pounds to kilograms
    weight_lbs = params[:snapshot][:weightLbs].to_f
    @snapshot.weight_kg = (weight_lbs * 0.453592).round(2)

    # Convert height from feet and inches to centimeters
    height_feet = params[:snapshot][:heightFeet].to_i
    height_inches = params[:snapshot][:heightInches].to_f
    total_height_inches = (height_feet * 12) + height_inches
    @snapshot.height_cm = (total_height_inches * 2.54).round(2)

    # Convert goal weight from pounds to kilograms
    goal_weight_lbs = params[:snapshot][:goal_weight_lbs].to_f
    @snapshot.goal_weight_kg = (goal_weight_lbs * 0.453592).round(2)

    # Calculate predicted_time_weeks
    weight_difference = @snapshot.weight_kg - @snapshot.goal_weight_kg
    calorie_difference_per_week = @snapshot.calorie_deficit_or_surplus_per_day * 7 / 7700.0
    @snapshot.predicted_time_weeks = (weight_difference / calorie_difference_per_week).ceil
    if @snapshot.predicted_time_weeks < 0
      @snapshot.predicted_time_weeks = (weight_difference / -calorie_difference_per_week).ceil
    end

    @snapshots = Snapshot.where(user_id: current_user.id)

    respond_to do |format|
      if @snapshot.save
        format.html { redirect_to snapshot_url(@snapshot), notice: "Snapshot was successfully created." }
        format.json { render :show, status: :created, location: @snapshot }
      else
        # Debugging output
        customized_errors = @snapshot.errors.full_messages.map do |msg|
          if msg.include?('Height cm')
            height_cm = @snapshot.height_cm
            height_feet = (height_cm / 30.48).to_i
            height_inches = ((height_cm / 2.54) % 12).round(2)
            msg.gsub('Height cm', "Height must be less than #{height_feet} feet #{height_inches} inches")
          elsif msg.include?('Weight kg')
            weight_kg = @snapshot.weight_kg
            weight_lbs = (weight_kg / 0.453592).round(2)
            msg.gsub('Weight kg', "Weight must be less than #{weight_lbs} lbs (#{weight_kg} kg)")
          else
            msg
          end
        end
        flash[:alert] = "Snapshot save failed: #{customized_errors.join(', ')}"
        Rails.logger.debug("Snapshot save failed: #{@snapshot.errors.full_messages.join(', ')}")
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end


  # PATCH/PUT /snapshots/1 or /snapshots/1.json
  def update
    respond_to do |format|
      if @snapshot.update(snapshot_params)
        format.html { redirect_to snapshot_url(@snapshot), notice: "Snapshot was successfully updated." }
        format.json { render :show, status: :ok, location: @snapshot }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @snapshot.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /snapshots/1 or /snapshots/1.json
  def destroy
    @snapshot.destroy!
    respond_to do |format|
      format.html { redirect_to snapshots_url, notice: "Snapshot was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end

  def snapshot_params
    params.require(:snapshot).permit(:height_cm, :weight_kg, :activity_level, :goal_weight_kg, :predicted_time_weeks, :calorie_deficit_or_surplus_per_day, :gender, :dob)
  end
end
