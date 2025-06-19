# spec/requests/notifications_spec.rb
require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  include Warden::Test::Helpers

  #テスト用のユーザーを1人作成
  let(:user)         { create(:user) }
  # 作成したユーザーが giver のポイントカードを生成
  let!(:point_card)  { create(:point_card, giver: user) }
  # ユーザーとポイントカードに紐づいた通知を1件作成
  let!(:notification){ create(:notification, user: user, point_card: point_card) }

  # Warden.test_mode! で変更されたセッション状態をリセットして、他のテストへの影響を防ぐ
  after { Warden.test_reset! }

  #------------------------------------------------------------
  # 一覧：GET /notifications
  #------------------------------------------------------------
  describe "GET /notifications" do
    # ログインしているときの挙動を確認
    context "when logged in" do
      # Wardenをテストモードに切り替え、ユーザーとしてログイン状態を模倣
      before do
        Warden.test_mode!
        login_as(user, scope: :user)
      end

      # 一覧ページにアクセスしたら、HTTPステータス200（成功）を返すことを確認
      it "returns success" do
        get notifications_path
        expect(response).to have_http_status(:ok)
      end
    end

    # 未ログインの場合、ログイン画面へリダイレクトされることを確認
    context "when not logged in" do
      it "redirects to login page" do
        get notifications_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  #------------------------------------------------------------
  # 詳細：GET /notifications/:id
  #------------------------------------------------------------
  describe "GET /notifications/:id" do
    context "when logged in" do
      before do
        Warden.test_mode!
        login_as(user, scope: :user)
      end

      # 詳細画面が正常に表示されるか確認
      it "shows the notification" do
        get notification_path(notification)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(notification.content)
      end

      # 通知が既読状態になるか
      it "marks the notification as read" do
        expect {
          get notification_path(notification)
        }.to change { notification.reload.read }.from(false).to(true)
      end

      # 他人の通知が見られないことを確認
      it "returns 404 when accessing other user's notification" do
        other_user = create(:user)
        other_notification = create(:notification,
                                    user: other_user,
                                    point_card: create(:point_card, giver: other_user))

        get notification_path(other_notification)
        expect(response).to have_http_status(:not_found)
      end

      # 存在しない通知にアクセスできないことを確認
      it "returns 404 when accessing non-existent notification" do
        get "/notifications/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    # 未ログインの場合、ログイン画面へリダイレクトされることを確認
    context "when not logged in" do
      it "redirects to login page" do
        get notification_path(notification)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
