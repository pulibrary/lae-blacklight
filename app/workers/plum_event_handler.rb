# frozen_string_literal: true
class PlumEventHandler
  include Sneakers::Worker
  from_queue "lae_#{Rails.env}_queue".freeze, WORKER_OPTIONS

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
