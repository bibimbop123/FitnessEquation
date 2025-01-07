class SnapshotsController < ApplicationController
  before_action :set_snapshot, only: %i[ show edit update destroy ]

  # GET /snapshots or /snapshots.json
  def index
    @snapshots = Snapshot.all
  end

  # GET /snapshots/1 or /snapshots/1.json
  def show
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
    weight_lbs = params.fetch("snapshot").fetch("weightLbs").to_f
    @snapshot.weight_kg = (weight_lbs * 0.453592).round(2)

    # Convert height from feet and inches to centimeters
    height_feet = params.fetch("snapshot").fetch("heightFeet").to_i
    height_inches = params.fetch("snapshot").fetch("heightInches").to_f
    total_height_inches = (height_feet * 12) + height_inches
    @snapshot.height_cm = (total_height_inches * 2.54).round(2)
    goal_weight_lbs = params.fetch("snapshot").fetch("goal_weight_lbs").to_f
    @snapshot.goal_weight_kg = (goal_weight_lbs * 0.453592).round(2)

    # how to calculate the predicted time in weeks when it's a surplus or deficit?
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
