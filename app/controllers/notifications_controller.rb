class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications
  end

  def show
    @notification = current_user.notifications.find_by!(id: params[:id])

    @card = @notification.point_card

    @notification.update!(read: true)

    render file: "public/404.html", status: :not_found unless @notification
  end
end