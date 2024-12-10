# == Schema Information
#
# Table name: snapshots
#
#  id                      :bigint           not null, primary key
#  activity_level          :string
#  calorie_deficit_per_day :integer
#  goal_weight_kg          :float
#  height_cm               :float
#  predicted_time_weeks    :integer
#  weight_kg               :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :bigint           not null
#
# Indexes
#
#  index_snapshots_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Snapshot < ApplicationRecord
  belongs_to :user

  validates :height_cm, presence: true, numericality: { greater_than: 0 }
  validates :weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :activity_level, presence: true, inclusion: { in: %w[low moderate high] }
  validates :goal_weight_kg, presence: true, numericality: { greater_than: 0 }
  validates :predicted_time_weeks, presence: true, numericality: { greater_than: 0 }
  validates :calorie_deficit_per_day, presence: true, numericality: { greater_than: 0 }

  def bmr
  end

  def tdee
  end

  def daily_calories
  end

end
