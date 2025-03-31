# frozen_string_literal: true

class KeepAliveJob < ApplicationJob
  queue_as :default

  def perform(*_args)
    # TODO: pass in url using args
    KeepAliveService.new('https://fitnessequation.onrender.com/').call
  end
end
