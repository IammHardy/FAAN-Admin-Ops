class NotificationService
  def self.notify(user:, title:, message:)
    return unless user.present?

    Notification.create!(
      user: user,
      title: title,
      message: message
    )
  end

  def self.dispatch_sent(dispatch)
    dispatch.dispatch_recipients.includes(:receiving_unit).each do |recipient|
      User.where(unit: recipient.receiving_unit, role: :unit_officer, active: true).find_each do |user|
        notify(
          user: user,
          title: "New Memo Received",
          message: "#{dispatch.reference_number} - #{dispatch.subject}"
        )
      end
    end
  end

  def self.dispatch_acknowledged(dispatch)
    admin_users.find_each do |user|
      notify(
        user: user,
        title: "Dispatch Acknowledged",
        message: "#{dispatch.reference_number} has been acknowledged."
      )
    end
  end

  def self.dispatch_filed(dispatch)
    admin_users.find_each do |user|
      notify(
        user: user,
        title: "Dispatch Filed",
        message: "#{dispatch.reference_number} has been filed."
      )
    end
  end

  def self.daily_log_submitted(log_report)
    reviewers.find_each do |user|
      notify(
        user: user,
        title: "Daily Log Submitted",
        message: "#{log_report.unit.name} submitted a daily log for #{log_report.report_date}."
      )
    end
  end

  def self.monthly_report_submitted(monthly_report)
    reviewers.find_each do |user|
      notify(
        user: user,
        title: "Monthly Report Submitted",
        message: "#{monthly_report.unit.name} submitted a monthly report for #{monthly_report.report_month&.strftime('%B %Y')}."
      )
    end
  end

  def self.incident_escalated(incident)
    reviewers.find_each do |user|
      notify(
        user: user,
        title: "Incident Escalated",
        message: "#{incident.incident_number} - #{incident.title} has been escalated."
      )
    end
  end

  def self.minutes_completed(minute)
    notify(
      user: minute.created_by,
      title: "Minutes Extraction Completed",
      message: "#{minute.title} has been processed successfully."
    )
  end

  def self.admin_users
    User.where(role: [:super_admin, :admin_officer], active: true)
  end

  def self.reviewers
    User.where(role: [:super_admin, :admin_officer, :reviewer], active: true)
  end
end