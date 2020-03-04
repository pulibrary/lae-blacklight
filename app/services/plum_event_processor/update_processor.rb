# frozen_string_literal: true
class PlumEventProcessor
  class UpdateProcessor < Processor
    def process
      PlumEventProcessor::DeleteProcessor.new(event).process unless PlumEventProcessor::CreateProcessor.new(event).process
      true
    end
  end
end
