# frozen_string_literal: true
class PlumEventProcessor
  class UnhandledEvent < Processor
    def process
      Rails.logger.info("Event is not valid for processing.")
      false
    end
  end
end
