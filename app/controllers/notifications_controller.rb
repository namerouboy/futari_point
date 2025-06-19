class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # 通知一覧
  def index
    @notifications = current_user.notifications
  end

  # 通知詳細
  def show
    @notification = current_user.notifications.find_by!(id: params[:id])

    @card = @notification.point_card

    # 既読
    @notification.update!(read: true)

    render file: "public/404.html", status: :not_found unless @notification
  end
end