require 'yaml'
LABEL_METADATA=YAML.load_file(Rails.root.join('config/label_metadata.yml'))
LAE_CONFIG = YAML.load_file(Rails.root.join('config/lae_conf.yml'))
