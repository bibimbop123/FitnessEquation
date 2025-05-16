module Snapshot::Chartkickable
  extend ActiveSupport::Concern

  included do
    # TODO

    # @weight_data = @snapshots.map { |snapshot| [snapshot.created_at, (snapshot.weight_kg / 0.453592).round(2)] }
    scope :chart_weight_kg_by_day, -> { chart_weight_by_day(:kg) }
    scope :chart_weight_lbs_by_day, -> { chart_weight_by_day(:lbs) }
    scope :chart_weight_by_day, ->(unit = :kg) { group_by_day(:created_at).sum(Snapshot.weight_expression(unit)) }

    # @snapshots_data = @snapshots.map { |snapshot| [snapshot.created_at, (snapshot.weight_kg / 0.453592).round(2)] }
    # @snapshots_count_data = @snapshots.group_by_day(:created_at).count
    # @predicted_time_data = @snapshots.map do |snapshot|
    #   [(snapshot.weight_kg / 0.453592).round(2), snapshot.predicted_time]
    # end.compact
    # @activity_level_data = @snapshots.group(:activity_level).count
    # @predicted_time_calorie_data = @snapshots.map do |snapshot|
    #   [snapshot.predicted_time, snapshot.calorie_deficit_or_surplus_per_day]
    # end
  end
end
