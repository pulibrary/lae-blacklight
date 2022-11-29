# frozen_string_literal: true
class PlumEventProcessor
  class UnknownEvent < Processor
    def process
      Rails.logger.info("Unable to process event type #{event_type}")
      false
    end
  end
end
