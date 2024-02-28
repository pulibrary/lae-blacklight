# frozen_string_literal: true
require "ddtrace"

Datadog.configure do |c|
  c.tracing.enabled = false unless Rails.env.production?
  c.env = Rails.env.to_s
  c.service = "dpul"
end
