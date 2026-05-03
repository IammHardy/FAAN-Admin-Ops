class BrevoEmailService
  def self.send_reset_password_email(user, token)
    reset_url = Rails.application.routes.url_helpers.edit_user_password_url(
      reset_password_token: token,
      host: "web-production-9272f.up.railway.app",
      protocol: "https"
    )

    Faraday.post("https://api.brevo.com/v3/smtp/email") do |req|
      req.headers["api-key"] = ENV["BREVO_API_KEY"]
      req.headers["Content-Type"] = "application/json"

      req.body = {
        sender: {
          name: "FAAN Admin Ops",
          email: ENV.fetch("MAILER_FROM")
        },
        to: [
          {
            email: user.email,
            name: user.display_name
          }
        ],
        subject: "Reset your FAAN Admin Ops password",
        htmlContent: "
          <h2>Reset your password</h2>
          <p>Hello #{user.display_name},</p>
          <p>Click the link below to reset your password:</p>
          <p><a href='#{reset_url}'>Reset Password</a></p>
          <p>If you did not request this, please ignore this email.</p>
        "
      }.to_json
    end
  end
end