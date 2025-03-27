# frozen_string_literal: true

class SnapshotsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_snapshot, only: %i[show edit update destroy]

  # GET /snapshots or /snapshots.json
  def index
    @snapshots = Snapshot.where(user: current_user).includes([:user])
  end

  # GET /snapshots/1 or /snapshots/1.json
  def show
    processor = SnapshotProcessor.new(@snapshot)
    show_values = processor.calculate_show_values

    @weightLbs = show_values[:weight_lbs].round(0)
    @height_feet = show_values[:height_feet].round(0)
    @height_inches = show_values[:height_inches].round(1)
    @goal_weight_lbs = show_values[:goal_weight_lbs].round(0)
    @calorie_deficit_or_surplus_per_day = @snapshot.calorie_deficit_or_surplus_per_day.to_i
  end

  # GET /snapshots/new
  def new
    @snapshot = Snapshot.new
    @snapshots = Snapshot.where(user: current_user).includes([:user])

  end

  # GET /snapshots/1/edit
  def edit; end

  def create
    @snapshot = current_user.snapshots.new(snapshot_params) # Associate with current_user
    processor = SnapshotProcessor.new(@snapshot, preprocess_virtual_params)
    processor.call
  
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
        format.html { redirect_to snapshot_url(@snapshot), notice: 'Snapshot was successfully updated.' }
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
      format.html { redirect_to snapshots_url, notice: 'Snapshot was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_snapshot
    @snapshot = Snapshot.find(params[:id])
  end

  def snapshot_params
    params.require(:snapshot).permit(:weight_kg, :activity_level, :goal_weight_kg, :predicted_time_weeks,
                                     :calorie_deficit_or_surplus_per_day, :gender, :dob)
  end

  def virtual_params
    params.require(:snapshot).permit(:weightLbs, :heightFeet, :heightInches, :goal_weight_lbs,
                                     :calorie_deficit_or_surplus_per_day)
  end

  def preprocess_virtual_params
    virtual_params.tap do |vp|
      if vp[:calorie_deficit_or_surplus_per_day].present?
        vp[:calorie_deficit_or_surplus_per_day] =
          vp[:calorie_deficit_or_surplus_per_day].to_s.gsub(/[^\d-]/,
                                                            '')
      end
    end
  end
end
