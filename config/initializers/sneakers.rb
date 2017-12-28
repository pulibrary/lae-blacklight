# frozen_string_literal: true
require 'sneakers'
require 'sneakers/handlers/maxretry'
require_relative 'lae_config'
Sneakers.configure(
  amqp: LAE.config["events"]["server"],
  exchange: LAE.config["events"]["exchange"],
  exchange_type: :fanout,
  handler: Sneakers::Handlers::Maxretry
)
Sneakers.logger.level = Logger::INFO

WORKER_OPTIONS = {
  ack: true,
  threads: 10,
  prefetch: 10,
  timeout_job_after: 60,
  heartbeat: 5,
  amqp_heartbeat: 10,
  retry_timeout: 60 * 1000 # 60 seconds
}.freeze

# incorporate the env to prevent staging / prod conflicts
SNEAKERS_QUEUE = "lae_#{Rails.env}_queue"
