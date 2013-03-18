class UserMailer < ActionMailer::Base
  default from: "\"#{Rails.configuration.settings['app_full_name']}\" <#{Rails.configuration.settings['email_address']}>"

  def activation_mail(profile, password)
    @profile = profile
    @password = password
    mail(
      to: "\"#{@profile.name}\" <#{@profile.email}>",
      subject: "Activate your account"
    )
  end

  def reset_password_mail(profile, password)
    @profile = profile
    @password = password
    mail(
      to: "\"#{@profile.name}\" <#{@profile.email}>",
      subject: "Your password has been reset"
    )
  end
end