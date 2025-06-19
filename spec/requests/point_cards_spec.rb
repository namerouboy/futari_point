require 'rails_helper'

RSpec.describe "PointCards", type: :request do
  include Warden::Test::Helpers

  # ─────────────────────────────────────────
  # テスト用データ
  # ─────────────────────────────────────────
  let(:giver)      { create(:user) }
  let(:receiver)   { create(:user) }
  let!(:card)      { create(:point_card, giver: giver) }
  # recieverがカードを受け取り
  let!(:received)  { receiver.received_point_cards << card && card }

  after { Warden.test_reset! }

  # ─────────────────────────────────────────
  # 1. ホーム画面：GET /
  # ─────────────────────────────────────────
  describe "GET /" do
    context "when logged in" do
      # receiverとしてログインした状態でテスト開始
      before { login_as(receiver, scope: :user) }

      # カードのタイトルが表示されることを確認
      it "renders the default card" do
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(card.title)
      end
    end

    # 未ログインの場合ログインページにリダイレクト
    context "when not logged in" do
      it "redirects to login page" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  # ─────────────────────────────────────────
  # 2. カード一覧：GET /point_cards
  # ─────────────────────────────────────────
  describe "GET /point_cards" do
    before  { login_as(receiver, scope: :user) }

    # カード一覧が表示される
    it "shows received cards" do
      get point_cards_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(card.title)
    end
  end

  # ─────────────────────────────────────────
  # 3. カード詳細：GET /point_cards/:id
  # ─────────────────────────────────────────
  describe "GET /point_cards/:id" do
    it "404s for someone else’s card" do
      # 他人のカード詳細が見れないことを確認
      login_as(create(:user), scope: :user)
      get point_card_path(card)
      expect(response).to have_http_status(:not_found)
    end
  end

  # ─────────────────────────────────────────
  # 4. スタンプ押下：PATCH /point_cards/:id/add_stamp
  # ─────────────────────────────────────────
  describe "PATCH /point_cards/:id/add_stamp" do
    before { login_as(receiver, scope: :user) }

    # スタンプが押せることを確認
    it "creates a PointRecord and bumps current_points" do
      expect {
        post add_stamp_point_card_path(card), params: { id: card.id }, headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
      }.to change { card.reload.current_points }.by(1)
    end
  end

  # ─────────────────────────────────────────
  # 5. 設定画面：GET /point_cards/:id/settings
  # ─────────────────────────────────────────
  describe "GET /point_cards/:id/settings" do
    before { login_as(receiver, scope: :user) }

    # 設定画面に「ごほうび」という文言が表示されることを確認
    it "shows settings form" do
      get settings_point_card_path(card)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("ごほうび")
    end
  end

  # ─────────────────────────────────────────
  # 6. 設定更新：PATCH /point_cards/:id/settings
  # ─────────────────────────────────────────
  describe "PATCH /point_cards/:id/settings" do
    before { login_as(receiver, scope: :user) }

    # ごほうびとSpecialDayが保存されることを確認
    it "updates special_days and rewards" do
      patch settings_point_card_path(card), params: {
        point_card: {
          special_days_attributes: [{ date: 5,  multiplier: 2 }],
          rewards_attributes:      [{ required_points: 10, name: "おやつ", message: "達成！" }]
        }
      }
      expect(response).to redirect_to(settings_point_card_path(card))
      card.reload
      expect(card.special_days.count).to eq(1)
      expect(card.rewards.first.name).to eq("おやつ")
    end
  end

  # ─────────────────────────────────────────
  # 7. PIN 受け取り：POST /point_cards (receive_by_pin)
  # ─────────────────────────────────────────
  describe "POST /point_cards receive by PIN" do
    before { login_as(receiver, scope: :user) }

    # カードを受け取って、一覧に追加されることを確認
    it "adds card to receiver" do
      post point_cards_path, params: { pin_code: card.pin_code, commit: "PIN で受け取る" }
      expect(response).to redirect_to(point_cards_path)
      expect(receiver.received_point_cards).to include(card)
    end
  end

  # ─────────────────────────────────────────
  # 8. 新規カード発行：POST /point_cards (generate_new_card)
  # ─────────────────────────────────────────
  describe "POST /point_cards generate new card" do
    before { login_as(giver, scope: :user) }

    # 新規カードが発行できることを確認
    it "creates a new given card and redirects to issued page" do
      expect {
        post point_cards_path, params: {
          point_card: { title: "テストカード", message: "よろしく！" },
          commit:     "新しいカードを作る"
        }
      }.to change { giver.given_point_cards.count }.by(1)
      new_card = giver.given_point_cards.last
      expect(response).to redirect_to(issued_point_card_path(new_card))
    end
  end
end