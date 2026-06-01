class ApplicationMailer < ActionMailer::Base
  default from: "noreply@#{Rails.configuration.x.mail_from_domain}"
  layout "mailer"
end
