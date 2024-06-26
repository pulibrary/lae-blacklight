# frozen_string_literal: true
class Contact < MailForm::Base
  attribute :name,      validate: true
  attribute :email,     validate: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  attribute :message
  attribute :nickname, captcha: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      subject: "Message from LAE Project",
      to: "digital-library@princeton.libanswers.com",
      from: %("#{name}" <#{email}>)
    }
  end
end
