# frozen_string_literal: true
class PlumEventProcessor
  attr_reader :event
  def initialize(event)
    @event = event
  end

  delegate :process, to: :processor

  private

    def event_type
      event["event"]
    end

    def processor
      return UnhandledEvent.new(event) unless manifest_url.include?("ephemera_folders")
      case event_type
      when "CREATED"
        CreateProcessor.new(event)
      when "UPDATED"
        UpdateProcessor.new(event)
      when "DELETED"
        DeleteProcessor.new(event)
      else
        UnknownEvent.new(event)
      end
    end

    def manifest_url
      event["manifest_url"]
    end
end
