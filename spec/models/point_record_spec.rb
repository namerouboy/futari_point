require 'rails_helper'

RSpec.describe PointRecord, type: :model do
  # let のスコープを describe ブロックの外側に移動し、必要に応じて使用する
  let(:point_card) { create(:point_card) }
  let(:giver) { point_card.giver }
  let!(:reward_10_points) { create(:reward, point_card: point_card, required_points: 10, message: "10ポイント達成！") }
  let!(:reward_20_points) { create(:reward, point_card: point_card, required_points: 20, message: "20ポイント達成！") }

  it { is_expected.to belong_to(:point_card) }
  it { is_expected.to belong_to(:added_by_user).class_name('User') }

  it { is_expected.to validate_numericality_of(:points).is_greater_than(0) }

  describe '#check_reward' do
    context 'ごほうび達成通知' do
      it 'creates a notification when a reward is reached' do
        expect {
          create(:point_record, point_card: point_card, points: 10)
        }.to change(Notification, :count).by(1) # 10点達成のごほうび通知のみ

        notification = Notification.last
        expect(notification.user).to eq(giver)
        expect(notification.point_card).to eq(point_card)
        expect(notification.content).to eq("10ポイント達成！")
      end

      it 'creates multiple notifications if multiple rewards are reached in one go' do
        # 0ポイントから20ポイントまで一気に加算した場合を想定
        # 10点達成のごほうび通知、20点達成のごほうび通知、満タン通知の合計3つ
        expect {
          create(:point_record, point_card: point_card, points: 20)
        }.to change(Notification, :count).by(3) # 10点達成と20点達成のごほうび通知、および満タン通知
      end
    end

    context '満タン通知' do
      it 'creates a notification when points become full (multiple of 20)' do
        # 10ポイントすでに持っている状態で、10ポイント追加して20ポイント満タンになるケース
        create(:point_record, point_card: point_card, points: 10) # 事前に10ポイント
        # 10ポイント追加すると20ポイントになるので、20点達成のごほうび通知と満タン通知の2つが作成される
        expect {
          create(:point_record, point_card: point_card, points: 10) # さらに10ポイント追加で合計20ポイント
        }.to change(Notification, :count).by(2) # 20点達成のごほうび通知と満タン通知
        expect(Notification.last.content).to eq("ポイントが満タンになりました！")
      end

      it 'creates a notification when points are added and result in an exact multiple of 20' do
        # 0ポイントから20ポイントまで一気に加算した場合
        # 10点達成のごほうび通知、20点達成のごほうび通知、満タン通知の合計3つ
        expect {
          create(:point_record, point_card: point_card, points: 20)
        }.to change(Notification, :count).by(3) # 10点達成と20点達成のごほうび通知、および満タン通知
        expect(Notification.last.content).to eq("ポイントが満タンになりました！")
      end
    end
  end
end