# frozen_string_literal: true

# == Schema Information
#
# Table name: exercises
#
#  id                 :bigint           not null, primary key
#  name               :string
#  reps               :integer
#  sets               :integer
#  weight             :float
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  workout_routine_id :bigint           not null
#
# Indexes
#
#  index_exercises_on_workout_routine_id  (workout_routine_id)
#
# Foreign Keys
#
#  fk_rails_...  (workout_routine_id => workout_routines.id)
#
class Exercise < ApplicationRecord
  belongs_to :workout_routine, touch: true

  validates :name, presence: true
  validates :reps, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :sets, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :weight, presence: true, numericality: { greater_than: 0 }

  include Volumable
end
