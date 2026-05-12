class ProcessMinuteJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 10.seconds, attempts: 3

  def perform(minute_id)
    minute = Minute.find(minute_id)
    MinutesExtractionService.new(minute).call
  end
end