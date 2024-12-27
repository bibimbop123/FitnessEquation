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
    @snapshot.user = current_user 
    @snapshots = Snapshot.where(user: current_user)
  end
  
    # GET /snapshots/1/edit
  def edit
  end
  
    # POST /snapshots or /snapshots.json
  def create
    @snapshot = Snapshot.new(snapshot_params)
    @snapshot.user = current_user
    @snapshot.user_id = params.fetch("user_id")
    @snapshot.height_cm = params.fetch("height_cm")
    @snapshot.weight_kg = params.fetch("weight_kg")
    @snapshot.activity_level = params.fetch("activity_level")
    @snapshot.goal_weight_kg = params.fetch("goal_weight_kg")
    @snapshot.predicted_time_weeks = params.fetch("predicted_time_weeks")
    @snapshot.calorie_deficit_per_day = params.fetch("calorie_deficit_per_day")
    @snapshot.gender = params.fetch("gender")
    @snapshot.age = params.fetch("age")
  
    if @snapshot.gender.nil?
      flash[:alert] = "Gender is required for BMR calculation"
      render({ :template => "snapshots/new" })
    elsif @snapshot.save
      # Redirect or render a success page
      # redirect_to snapshot_path(@snapshot)
    else
      # Re-render the form with errors
      render({ :template => "snapshots/new" })
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
      params.require(:snapshot).permit(:height_cm, :weight_kg, :activity_level, :goal_weight_kg, :predicted_time_weeks, :calorie_deficit_per_day, :gender, :age)
    end
  end
