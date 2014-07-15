class NotificationMailer < ActionMailer::Base
  default from: "\"#{Rails.configuration.settings['app_full_name']}\" <#{Rails.configuration.settings['email_address']}>"

  def notify_guardian_for_student(notifications)
    @notifications = notifications
    puts "\"#{@notifications.guardian.name}\" <#{@notifications.guardian.email}>"
    mail(
      to: "\"#{@notifications.guardian.name}\" <#{@notifications.guardian.email}>",
      subject: "Updates about #{@notifications.student.name} on #{Rails.configuration.settings['app_full_name']}"
    )
  end
end