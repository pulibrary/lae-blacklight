# frozen_string_literal: true
class PlumEventProcessor
  class UpdateProcessor < Processor
    def process
      unless PlumEventProcessor::CreateProcessor.new(event).process
        PlumEventProcessor::DeleteProcessor.new(event).process
      end
      true
    end
  end
end
