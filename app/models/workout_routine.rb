# frozen_string_literal: true

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
  tracked owner: ->(controller, _model) { controller && controller.current_user }

  belongs_to :user, touch: true
  has_many :exercises, dependent: :destroy
  after_create :track_creation
  after_destroy :track_deletion

  validates :name, presence: true

  include Workoutable
end
