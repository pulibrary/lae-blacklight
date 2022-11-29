# -*- encoding : utf-8 -*-
# frozen_string_literal: true
# Only works for documents with a #to_marc right now.
class RecordMailer < ApplicationMailer
  def email_record(documents, details, url_gen_params)
    # raise ArgumentError.new("RecordMailer#email_record only works with documents with a #to_marc") unless document.respond_to?(:to_marc)

    subject = I18n.t('blacklight.email.text.subject', count: documents.length, title: (begin
                                                                                               documents.first.to_semantic_values[:title]
                                                                                       rescue
                                                                                         'N/A'
                                                                                             end))

    @documents      = documents
    @message        = details[:message]
    @url_gen_params = url_gen_params

    mail(to: details[:to], subject:,
         from: 'no-reply@lae.princeton.edu')
  end

  def sms_record(documents, details, url_gen_params)
    @documents      = documents
    @url_gen_params = url_gen_params
    mail(to: details[:to], subject: "")
  end
end
