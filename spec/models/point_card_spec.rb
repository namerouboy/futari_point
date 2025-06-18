require 'rails_helper'

RSpec.describe PointCard, type: :model do
  # let のスコープを describe ブロックの外側に移動し、必要に応じて使用する
  let(:point_card) { create(:point_card) }
  let(:reward) { create(:reward, point_card: point_card, required_points: 20) }

  it { is_expected.to belong_to(:giver).class_name('User') }
  it { is_expected.to belong_to(:receiver).class_name('User').optional }
  it { is_expected.to have_many(:point_records).dependent(:destroy) }
  it { is_expected.to have_many(:special_days).dependent(:destroy) }
  it { is_expected.to have_many(:notifications).dependent(:destroy) }
  it { is_expected.to have_many(:rewards).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_numericality_of(:max_point).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:current_round).is_greater_than(0) }

  describe '#regenerate_pin_code' do
    it 'sets a pin_code before creation' do
      new_point_card = build(:point_card, pin_code: nil)
      new_point_card.save
      expect(new_point_card.pin_code).to be_present
      expect(new_point_card.pin_code.length).to eq(6) # SecureRandom.hex(3) generates 6 characters
    end
  end

  describe '#current_points' do
    it 'returns the sum of points from associated point records' do
      current_point_card = create(:point_card) # このテストケース専用のPointCardを作成
      create_list(:point_record, 3, points: 5, point_card: current_point_card)
      expect(current_point_card.current_points).to eq(15)
    end
  end

  describe '#full?' do
    context 'when current points are a multiple of 20 and not zero' do
      it 'returns true' do
        current_point_card = create(:point_card) # このテストケース専用のPointCardを作成
        create(:point_record, points: 20, point_card: current_point_card)
        expect(current_point_card.full?).to be true
      end
    end

    context 'when current points are not a multiple of 20' do
      it 'returns false' do
        current_point_card = create(:point_card) # このテストケース専用のPointCardを作成
        create(:point_record, points: 15, point_card: current_point_card)
        expect(current_point_card.full?).to be false
      end
    end

    context 'when current points are zero' do
      it 'returns false' do
        current_point_card = create(:point_card) # このテストケース専用のPointCardを作成
        expect(current_point_card.full?).to be false
      end
    end
  end

  describe '#reached_reward' do
    # 各テストケースで個別にpoint_cardとrewardを作成し、関連を明確にする
    # it 'returns the reward if current points match a required_points for a reward' do
    #   pc = create(:point_card)
    #   r = create(:reward, point_card: pc, required_points: 20)
    #   create(:point_record, points: 20, point_card: pc)
    #   expect(pc.reached_reward).to eq(r)
    # end

    it 'returns nil if no reward matches current points' do
      pc = create(:point_card)
      create(:reward, point_card: pc, required_points: 20) # 別の報酬を設定
      create(:point_record, points: 10, point_card: pc) # 10ポイントなので報酬には到達しない
      expect(pc.reached_reward).to be_nil
    end
  end

  describe 'accepts_nested_attributes_for :special_days' do
    let(:giver_user) { create(:user) }

    it 'rejects special_day if date is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        special_days_attributes: [{ date: nil, multiplier: 2 }] # nil は integer でも blank
      ))
      expect(point_card.special_days).to be_empty
    end

    it 'accepts special_day if date is present' do
      point_card = PointCard.create!(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        special_days_attributes: [{ date: Date.current.day, multiplier: 2 }] # ここを修正: Date.current.day (整数) を渡す
      ))
      expect(point_card.special_days.count).to eq(1)
      expect(point_card.special_days.first.date).to eq(Date.current.day) # 期待値も整数に合わせる
    end
  end

  describe 'accepts_nested_attributes_for :rewards' do
    let(:giver_user) { create(:user) }

    it 'rejects reward if required_points is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: "Test Reward", message: "Yay!", required_points: nil }]
      ))
      expect(point_card.rewards).to be_empty
    end

    it 'rejects reward if message is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: "Test Reward", message: nil, required_points: 5 }]
      ))
      expect(point_card.rewards).to be_empty
    end

    it 'rejects reward if name is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: nil, message: "Yay!", required_points: 5 }]
      ))
      expect(point_card.rewards).to be_empty
    end

    it 'accepts reward if required_points, message, and name are present' do
      point_card = PointCard.create!(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: "Test Reward", message: "Yay!", required_points: 5 }]
      ))
      expect(point_card.rewards.count).to eq(1)
      expect(point_card.rewards.first.name).to eq("Test Reward")
    end
  end
end