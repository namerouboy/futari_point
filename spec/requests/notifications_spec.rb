# spec/requests/notifications_spec.rb
require 'rails_helper'

RSpec.describe "Notifications", type: :request do
  include Warden::Test::Helpers

  let(:user)         { create(:user) }
  let!(:point_card)  { create(:point_card, giver: user) }
  let!(:notification){ create(:notification, user: user, point_card: point_card) }

  after { Warden.test_reset! }

  #------------------------------------------------------------
  # 一覧：GET /notifications
  #------------------------------------------------------------
  describe "GET /notifications" do
    context "when logged in" do
      before do
        Warden.test_mode!
        login_as(user, scope: :user)
      end

      it "returns success" do
        get notifications_path
        expect(response).to have_http_status(:ok)
      end
    end

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

      it "shows the notification" do
        get notification_path(notification)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(notification.content)
      end

      it "marks the notification as read" do
        expect {
          get notification_path(notification)
        }.to change { notification.reload.read }.from(false).to(true)
      end

      it "returns 404 when accessing other user's notification" do
        other_user = create(:user)
        other_notification = create(:notification,
                                    user: other_user,
                                    point_card: create(:point_card, giver: other_user))

        get notification_path(other_notification)
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 when accessing non-existent notification" do
        get "/notifications/999999"
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not logged in" do
      it "redirects to login page" do
        get notification_path(notification)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
