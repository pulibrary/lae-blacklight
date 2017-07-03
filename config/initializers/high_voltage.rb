# frozen_string_literal: true
# See https://github.com/thoughtbot/high_voltage#top-level-routes
HighVoltage.configure do |config|
  config.route_drawer = HighVoltage::RouteDrawers::Root
  config.routes = false
end
