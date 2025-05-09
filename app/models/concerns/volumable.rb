# frozen_string_literal: true

# Volumeable
module Volumable
  extend ActiveSupport::Concern

  def volume
    reps * sets * weight
  end
end
