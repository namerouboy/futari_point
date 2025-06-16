class NotificationsController < ApplicationController
  require "ostruct"

  # 仮データを共通メソッドに
  def fake_notifications
    [
      OpenStruct.new(id: 1, title: "おやつ獲得！", body: "5ポイント達成！今日はアイスを食べよう！",
                     created_at: Time.zone.today),
      OpenStruct.new(id: 2, title: "ごほうび解放！", body: "10ポイント達成！映画を観に行こう！",
                     created_at: 1.day.ago)
    ]
  end

  def index
    @notifications = fake_notifications
  end

  def show
    @notification = fake_notifications.find { |n| n.id == params[:id].to_i }
    render file: "public/404.html", status: :not_found unless @notification
  end
end