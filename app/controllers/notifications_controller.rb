class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications
  .recent_first
  .page(params[:page])
  .per(20)
  end

  def mark_as_read
    notification = current_user.notifications.find(params[:id])
    notification.mark_as_read!

    redirect_to notifications_path, success: "Notification marked as read."
  end
end