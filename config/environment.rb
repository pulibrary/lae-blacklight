# frozen_string_literal: true
# Load the Rails application.
require File.expand_path('../application', __FILE__)

Mime::Type.register 'application/rdf+xml', :rdf
Mime::Type.register 'text/turtle', :ttl
Mime::Type.register 'application/ld+json', :jsonld

# Initialize the Rails application.
Rails.application.initialize!
