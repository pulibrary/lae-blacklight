# frozen_string_literal: true
class PlumEventProcessor
  class UnhandledEvent < Processor
    attr_reader :event
    def initialize(event)
      @event = event
    end

    def process
      Rails.logger.info("Event is not valid for processing.")
      false
    end
  end
end
