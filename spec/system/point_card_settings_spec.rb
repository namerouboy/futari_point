require "rails_helper"
require "warden/test/helpers"

RSpec.describe "PointCardSettings", type: :system do
  include Warden::Test::Helpers
  after  { Warden.test_reset! }
  before { driven_by :rack_test }

  let(:giver)     { create(:user) }
  let(:receiver)  { create(:user) }

  let!(:card) do
    create(:point_card, giver: giver, title: "お手伝いカード").tap do |c|
      receiver.received_point_cards << c
    end
  end

  it "adds a reward row and saves" do
    login_as(receiver, scope: :user)

    visit settings_point_card_path(card)

    all("input[placeholder='ポイント']").last.fill_in(with: 15)
    all("input[placeholder='ごほうび名']").last.fill_in(with: "スペシャルお菓子")
    all("input[placeholder='メッセージ']").last.fill_in(with: "よく頑張りました！")

    click_button "保存する"
    expect(page).to have_content("保存しました")
    expect(card.reload.rewards.pluck(:name)).to include("スペシャルお菓子")
  end
end