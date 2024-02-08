# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  def set_locale
    I18n.locale = params[:locale] || header_locale
  end

  # default all links to the user's current locale to preserve choice across pageviews
  def default_url_options
    { locale: I18n.locale }
  end

  private

    # parse the header and return the first match
    # return I18n default if no match found
    def header_locale
      options = request.env.fetch('HTTP_ACCEPT_LANGUAGE', '').split(',')
      # clear out preference values; assume they'll be in order
      options.map! { |v| v.split(';')[0] }
      options.each do |v|
        return locale_matches[v] if locale_matches.keys.include?(v)
      end
      I18n.default_locale
    end

    # ensure a generalized language like 'pt' matches a regionalized one like 'pt-BR'
    def locale_matches
      matches = {}
      I18n.available_locales.map(&:to_s).each do |locale|
        matches[locale] = locale
        matches[locale[0, 2]] = locale if locale.length > 2
      end
      matches
    end
end
