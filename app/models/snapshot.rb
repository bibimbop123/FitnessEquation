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
end
