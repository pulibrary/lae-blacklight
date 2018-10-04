# frozen_string_literal: true

module I18n
  class LaeExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        Rails.logger.warn("Missing translation for: #{key}")
        # Split key value from nodes, capitalize, and return as default
        /(?<=\.)[^.]*$/.match(key).to_s.capitalize
      else
        super
      end
    end
  end
end

I18n.exception_handler = I18n::LaeExceptionHandler.new
