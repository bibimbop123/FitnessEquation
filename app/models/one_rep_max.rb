# == Schema Information
#
# Table name: one_rep_maxes
#
#  id          :bigint           not null, primary key
#  exercise    :string
#  one_rep_max :float
#  reps        :integer
#  weight_lbs  :float
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_one_rep_maxes_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class OneRepMax < ApplicationRecord
  belongs_to :user

  # Validations
  validates :exercise, presence: true
  validates :weight_lbs, numericality: { greater_than: 0 }
  validates :reps, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 10 }

  # Epley formula for 1RM
  def calculate_one_rep_max
    self.one_rep_max = (weight_lbs * (1 + reps / 30.0)).round(2)
  end
end