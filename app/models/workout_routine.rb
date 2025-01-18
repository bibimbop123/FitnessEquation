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
  belongs_to :user
  has_many :exercises, dependent: :destroy

  validates :name, presence: true

  def total_volume
    exercises.sum(&:volume)
  end
end
