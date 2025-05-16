module OneRepMax::Chartkickable
  extend ActiveSupport::Concern

  included do
    # TODO
    @one_rep_max_data = @one_rep_maxes.map { |one_rep_max| [one_rep_max.created_at, one_rep_max.calculate_one_rep_max] }
    @one_rep_max_count_data = @one_rep_maxes.group_by_day(:created_at).count
  end
end
