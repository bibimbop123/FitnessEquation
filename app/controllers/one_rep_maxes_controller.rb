class OneRepMaxesController < ApplicationController
  before_action :authenticate_user!
  def index
    @one_rep_maxes = OneRepMax.where(user: current_user).order(created_at: :desc).limit(10)

    respond_to do |format|
      format.html
      format.json { render json: @one_rep_maxes }
    end
  end

  def new
    @one_rep_max = OneRepMax.new
    @one_rep_max.user = current_user
    @one_rep_maxes = OneRepMax.where(user: current_user).includes([:user])
  end
  
  def show
    @one_rep_max = OneRepMax.find(params[:id])
  end

  def create
    @one_rep_max = OneRepMax.new(one_rep_max_params)
    @one_rep_max.user = current_user
    @one_rep_max.weight_lbs = one_rep_max_params[:weight_lbs].to_f
    @one_rep_max.reps = one_rep_max_params[:reps].to_i
    @one_rep_max.exercise = one_rep_max_params[:exercise]
    @one_rep_max.calculate_one_rep_max

    respond_to do |format|
      if @one_rep_max.save
        @one_rep_max.create_activity(key: 'one_rep_max.create',owner: current_user)
        format.html { redirect_to @one_rep_max, notice: "One rep max was successfully created." }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @one_rep_max = OneRepMax.find(params[:id])
    @one_rep_max.destroy
    respond_to do |format|
      format.html { redirect_to one_rep_maxes_url, notice: "One rep max was successfully destroyed." }
    end
  end

  private

  def one_rep_max_params
    params.require(:one_rep_max).permit(:exercise, :weight_lbs, :reps)
  end
end
