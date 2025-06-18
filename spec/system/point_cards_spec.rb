require 'rails_helper'

RSpec.describe "PointCards", type: :system do
  before { driven_by :rack_test }

  let(:giver)     { create(:user) }
  let(:receiver)  { create(:user) }

  let!(:card) do
    create(:point_card, giver: giver, title: "お手伝いカード").tap do |c|
      receiver.received_point_cards << c   # 受け取り登録
    end
  end

  it "shows list and stamps the card" do
    # ログイン
    visit new_user_session_path
    fill_in "Email",    with: receiver.email
    fill_in "Password", with: "password"
    click_button "Log in"

    # 一覧
    visit point_cards_path
    expect(page).to have_link(href: point_card_path(card))

    # 詳細へ
    find("a[href='#{point_card_path(card)}']").click
    expect(page).to have_current_path(point_card_path(card))

    # スタンプ押下
    expect {
      click_button "STAMP"
    }.to change { card.reload.current_points }.by(1)
  end
end
