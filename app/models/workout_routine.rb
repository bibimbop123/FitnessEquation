# frozen_string_literal: true

# == Schema Information
#
# Table name: workout_routines
#
#  id            :bigint           not null, primary key
#  acute_load    :integer
#  chronic_load  :integer
#  mood          :integer
#  name          :string
#  sleep_quality :integer
#  soreness      :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :bigint           not null
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
  before_validation :set_default_metrics, if: :new_record?
  after_initialize :set_default_metrics, if: :new_record?
  validates :mood, :sleep_quality, :soreness, presence: true,
                                              numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }

  def set_default_metrics
    self.mood ||= 5
    self.sleep_quality ||= 5
    self.soreness ||= 5
  end
end
