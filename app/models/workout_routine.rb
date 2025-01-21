# == Schema Information
#
# Table name: workout_routines
#
#  id         :bigint           not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_workout_routines_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class WorkoutRoutine < ApplicationRecord
  include PublicActivity::Model
  tracked owner: ->(controller, model) { controller && controller.current_user }

  belongs_to :user, touch: true
  has_many :exercises, dependent: :destroy
  after_create :track_creation
  after_destroy :track_deletion

  validates :name, presence: true

  def total_volume
    exercises.sum(&:volume)
  end

  def track_creation
    PublicActivity::Activity.create(
      key: 'workout.created',
      owner: user,
      trackable: self
    )
  end

  def track_deletion
    PublicActivity::Activity.create(
      key: 'workout.deleted',
      owner: user,
      trackable: self
    )
  end
end
