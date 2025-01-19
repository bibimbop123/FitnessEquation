class UsersController < ApplicationController
  def show
    @user = current_user
    @snapshots = @user.snapshots
    @workout_routines = @user.workout_routines
    @activities = PublicActivity::Activity.order(created_at: :desc)

    # Fetch the owners of the activities
    @activity_owners = @activities.map do |activity|
      owner = User.find_by(id: activity.owner_id)
      { activity: activity, owner: owner }
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
