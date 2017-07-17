# frozen_string_literal: true
class PlumEventHandler
  include Sneakers::Worker
  from_queue :lae
  WORKER_OPTIONS.merge(
    arguments: { 'x-dead-letter-exchange': 'lae-retry' }
  )

  def work(msg)
    msg = JSON.parse(msg)
    result = PlumEventProcessor.new(msg).process
    if result
      ack!
    else
      reject!
    end
  end
end
