# frozen_string_literal: true
module LAE
  def config
    @config ||= config_yaml.with_indifferent_access
  end

  def config_yaml
    YAML.safe_load(ERB.new(File.read(Rails.root.join("config", "config.yml"))).result)[Rails.env]
  end

  module_function :config, :config_yaml
end
