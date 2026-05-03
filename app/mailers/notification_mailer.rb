class NotificationMailer < ApplicationMailer
  default from: ENV.fetch("MAILER_FROM", "no-reply@faanadminops.com")

  def notification_email
    @user = params[:user]
    @title = params[:title]
    @message = params[:message]

    mail(
      to: @user.email,
      subject: @title
    )
  end
end