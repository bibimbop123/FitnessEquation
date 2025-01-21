class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @snapshots = @user.snapshots.page(params[:snapshot_page]).per(5).order(created_at: :desc)
    @workout_routines = @user.workout_routines.page(params[:workout_routine_page]).per(5).order(created_at: :desc)
    @activities = PublicActivity::Activity.order(created_at: :desc).limit(10).uniq { |activity| activity.id }

    # Fetch the owners of the activities
    @activity_owners = @activities.map do |activity|
      owner = User.find_by(id: activity.owner_id)
      { activity: activity, owner: owner }
    end

    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def edit
    @user = current_user
  end

  def update
    current_user.update!(user_params)
    redirect_to user_path(current_user)
  end

  private

  def user_params
    params.require(:user).permit(:height_cm, :weight_kg)
  end
end
