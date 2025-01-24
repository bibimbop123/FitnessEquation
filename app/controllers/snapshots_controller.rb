class SnapshotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_snapshot, only: %i[ show edit update destroy ]

  # GET /snapshots or /snapshots.json
  def index
    @snapshots = Snapshot.where(user: current_user).includes([:user])
    
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
    @snapshots = Snapshot.where(user: current_user).includes([:user])
  end
  # GET /snapshots/1/edit
  def edit
  end

  def create
    # Merge preprocessed parameters into snapshot_params
    @snapshot = current_user.snapshots.new(snapshot_params.merge(preprocess_virtual_params))
  
    if @snapshot.save
      redirect_to @snapshot, notice: 'Snapshot was successfully created.'
    else
      render :new
    end
  end
  
  # PATCH/PUT /snapshots/1 or /snapshots/1.json
  def update
    processor = SnapshotProcessor.new(@snapshot, preprocess_virtual_params)
    processor.call

    respond_to do |format|
      if @snapshot.save
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
    params.require(:snapshot).permit(
      :weight_kg, 
      :height_cm, 
      :activity_level, 
      :goal_weight_kg, 
      :calorie_deficit_or_surplus_per_day, 
      :gender, 
      :dob
    )
  end

  def virtual_params
    params.require(:snapshot).permit(:weightLbs, :heightFeet, :heightInches, :goal_weight_lbs, :calorie_deficit_or_surplus_per_day)
  end

  def preprocess_virtual_params
    processed = {}
  
    # Convert weight from lbs to kg
    if params[:snapshot][:weightLbs].present?
      processed[:weight_kg] = (params[:snapshot][:weightLbs].to_f * 0.453592).round(2)
    end
  
    # Convert height from feet and inches to cm
    if params[:snapshot][:heightFeet].present? && params[:snapshot][:heightInches].present?
      total_inches = (params[:snapshot][:heightFeet].to_i * 12) + params[:snapshot][:heightInches].to_i
      processed[:height_cm] = (total_inches * 2.54).round(2)
    end
  
    # Convert goal weight from lbs to kg
    if params[:snapshot][:goal_weight_lbs].present?
      processed[:goal_weight_kg] = (params[:snapshot][:goal_weight_lbs].to_f * 0.453592).round(2)
    end
  
    # Add calorie deficit or surplus
    if params[:snapshot][:calorie_deficit_or_surplus_per_day].present?
      processed[:calorie_deficit_or_surplus_per_day] = params[:snapshot][:calorie_deficit_or_surplus_per_day].to_i
    end
  
    processed
  end
  
end
