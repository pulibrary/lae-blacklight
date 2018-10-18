# frozen_string_literal: true
class PlumEventProcessor
  class DeleteProcessor < Processor
    def process
      index.delete_by_id(id)
      true
    end
  end
end
