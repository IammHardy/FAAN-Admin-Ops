class NotificationService
  def self.notify(user:, title:, message:, notifiable: nil)
    return unless user.present?

    Notification.create!(
      user: user,
      title: title,
      message: message,
      notifiable: notifiable,
      read_at: nil
    )
  end

  def self.dispatch_sent(dispatch)
    dispatch.dispatch_recipients.includes(:receiving_unit).each do |recipient|
      unit_users = User.where(unit: recipient.receiving_unit, role: :unit_officer, active: true)

      unit_users.each do |user|
        notify(
          user: user,
          title: "New Memo Received",
          message: "#{dispatch.reference_number} - #{dispatch.subject}",
          notifiable: dispatch
        )
      end
    end
  end

  def self.dispatch_acknowledged(dispatch)
    admin_users.each do |user|
      notify(
        user: user,
        title: "Dispatch Acknowledged",
        message: "#{dispatch.reference_number} has been acknowledged.",
        notifiable: dispatch
      )
    end
  end

  def self.dispatch_filed(dispatch)
    admin_users.each do |user|
      notify(
        user: user,
        title: "Dispatch Filed",
        message: "#{dispatch.reference_number} has been filed.",
        notifiable: dispatch
      )
    end
  end

  def self.daily_log_submitted(log_report)
    reviewers.each do |user|
      notify(
        user: user,
        title: "Daily Log Submitted",
        message: "#{log_report.unit.name} submitted a daily log for #{log_report.report_date}.",
        notifiable: log_report
      )
    end
  end

  def self.monthly_report_submitted(monthly_report)
    reviewers.each do |user|
      notify(
        user: user,
        title: "Monthly Report Submitted",
        message: "A monthly report has been submitted for review.",
        notifiable: monthly_report
      )
    end
  end

  def self.admin_users
    User.where(role: [:super_admin, :admin_officer], active: true)
  end

  def self.reviewers
    User.where(role: [:super_admin, :admin_officer, :reviewer], active: true)
  end
end