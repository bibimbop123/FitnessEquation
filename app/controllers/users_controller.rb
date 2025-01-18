class UsersController < ApplicationController
  def show
    @user = current_user
    @snapshots = @user.snapshots
    @workout_routines = @user.workout_routines
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
