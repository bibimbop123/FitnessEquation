module SetOneRepMaxConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_one_rep_max, only: %i[show edit update destroy]
  end

  private

  def set_one_rep_max
    @one_rep_max = OneRepMax.find(params[:id])
  end
end
