class UserMailer < ActionMailer::Base
  default from: "\"#{Rails.configuration.settings['app_full_name']}\" <#{Rails.configuration.settings['email_address']}>"

  def activation_mail(profile, password)
    @profile = profile
    @password = password
    mail(
      to: "\"#{@profile.full_name}\" <#{@profile.email}>", 
      subject: "User activation for #{Rails.configuration.settings['app_full_name']}"
    )
  end

  def reset_password_mail(profile, password)
    @profile = profile
    @password = password
    mail(
      to: "\"#{@profile.full_name}\" <#{@profile.email}>", 
      subject: "Password reset for #{Rails.configuration.settings['app_full_name']}"
    )
  end
end