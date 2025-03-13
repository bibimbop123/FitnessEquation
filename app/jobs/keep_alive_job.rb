class KeepAliveJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # TODO: pass in url using args
    KeepAliveService.new("https://fitnessequation.onrender.com/").call
  end
end
