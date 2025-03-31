# frozen_string_literal: true

module SetOneRepMaxConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_one_rep_max, only: %i[show edit update destroy]
  end

  def index
    @one_rep_maxes = @one_rep_maxes = OneRepMax.where(user: current_user).order(weight_lbs: :desc).limit(10)

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

  def show; end

  def create
    @one_rep_max = OneRepMax.new(one_rep_max_params)
    @one_rep_max.user = current_user
    @one_rep_max.weight_lbs = one_rep_max_params[:weight_lbs].to_f
    @one_rep_max.reps = one_rep_max_params[:reps].to_i

    if @one_rep_max.save
      redirect_to @one_rep_max, notice: 'One Rep Max was successfully created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @one_rep_max.update(one_rep_max_params)
      redirect_to @one_rep_max, notice: 'One Rep Max was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @one_rep_max.destroy
    redirect_to one_rep_maxes_url, notice: 'One Rep Max was successfully destroyed.'
  end

  private

  def one_rep_max_params
    params.require(:one_rep_max).permit(:exercise, :weight_lbs, :reps, :user_id)
  end

  def set_one_rep_max
    @one_rep_max = OneRepMax.find(params[:id])
  end
end
