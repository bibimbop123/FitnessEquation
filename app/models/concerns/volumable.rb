# frozen_string_literal: true

module Volumable
  extend ActiveSupport::Concern

  def volume
    reps * sets * weight
  end
end
