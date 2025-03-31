# frozen_string_literal: true

module Userable
  extend ActiveSupport::Concern

  def show
    @breadcrumbs = [
      { content: 'Welcome', href: root_path },
      { content: 'Home', href: user_path }
    ]
    @user = current_user
    @snapshots = @user.snapshots.page(params[:snapshot_page]).per(5).order(created_at: :desc)
    @workout_routines = @user.workout_routines.page(params[:workout_routine_page]).per(5).order(created_at: :desc)
    @activities = PublicActivity::Activity.order(created_at: :desc).limit(10).uniq(&:id)

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
    @breadcrumbs = [
      { content: 'Welcome', href: root_path },
      { content: 'Home', href: user_path },
      { content: 'Edit Profile', href: edit_user_path },
      { content: '@{current_user.username}', href: user_path(current_user) }
    ]
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
