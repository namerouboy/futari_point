require 'rails_helper'

RSpec.describe PointCard, type: :model do
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

  # ポイントカードを保存するとき、自動的に６文字のPINが発行されるかどうか
  describe '#regenerate_pin_code' do
    it 'sets a pin_code before creation' do
      # このテストケース専用のPointCardを作成(PINはnilの状態)
      new_point_card = build(:point_card, pin_code: nil)
      new_point_card.save
      # PINが空でないことを確認
      expect(new_point_card.pin_code).to be_present
      # PINが6文字になっていることを確認
      expect(new_point_card.pin_code.length).to eq(6)
    end
  end

  # currentpointが正しく計算されるかどうか
  describe '#current_points' do
    it 'returns the sum of points from associated point records' do
      # このテストケース専用のPointCardを作成
      current_point_card = create(:point_card)
      # 5ポイントずつ持つ PointRecord を3つ作成して紐づけ
      create_list(:point_record, 3, points: 5, point_card: current_point_card)
      # 合計が15になることを確認
      expect(current_point_card.current_points).to eq(15)
    end
  end

  # ポイント満タンがちゃんと計算されるかどうか
  describe '#full?' do
    # ポイントが満タンならtrueを返すことを確認
    context 'when current points are a multiple of 20 and not zero' do
      it 'returns true' do
        current_point_card = create(:point_card)
        create(:point_record, points: 20, point_card: current_point_card)
        expect(current_point_card.full?).to be true
      end
    end

    # 満タンでないならfalse
    context 'when current points are not a multiple of 20' do
      it 'returns false' do
        current_point_card = create(:point_card) # このテストケース専用のPointCardを作成
        create(:point_record, points: 15, point_card: current_point_card)
        expect(current_point_card.full?).to be false
      end
    end

    # 0でもfalse
    context 'when current points are zero' do
      it 'returns false' do
        current_point_card = create(:point_card)
        expect(current_point_card.full?).to be false
      end
    end
  end

  # 報酬ゲットがちゃんと計算されるかどうか
  describe '#reached_reward' do
  # 報酬に到達していない場合は nil
    it 'returns nil if no reward matches current points' do
      pc = create(:point_card)
      create(:reward, point_card: pc, required_points: 20) # 別の報酬を設定
      create(:point_record, points: 10, point_card: pc) # 10ポイントなので報酬には到達しない
      expect(pc.reached_reward).to be_nil
    end
  end

  # SpecialDayの設定で、dateが空の場合それが無視されるかどうか
  describe 'accepts_nested_attributes_for :special_days' do
    let(:giver_user) { create(:user) }

    # dateが空なら無視
    it 'rejects special_day if date is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        special_days_attributes: [{ date: nil, multiplier: 2 }] # nil は integer でも blank
      ))
      expect(point_card.special_days).to be_empty
    end

    # dateありなら保存される
    it 'accepts special_day if date is present' do
      point_card = PointCard.create!(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        special_days_attributes: [{ date: Date.current.day, multiplier: 2 }] 
      ))
      expect(point_card.special_days.count).to eq(1)
      expect(point_card.special_days.first.date).to eq(Date.current.day)
    end
  end

  # ごほうびの設定で、入力が空の場合それが無視されるかどうか
  describe 'accepts_nested_attributes_for :rewards' do
    let(:giver_user) { create(:user) }

    # required_pointsが空
    it 'rejects reward if required_points is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: "Test Reward", message: "Yay!", required_points: nil }]
      ))
      expect(point_card.rewards).to be_empty
    end

    # messageが空
    it 'rejects reward if message is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: "Test Reward", message: nil, required_points: 5 }]
      ))
      expect(point_card.rewards).to be_empty
    end

    # nameが空
    it 'rejects reward if name is blank' do
      point_card = PointCard.create(attributes_for(:point_card).merge(
        giver_id: giver_user.id,
        rewards_attributes: [{ name: nil, message: "Yay!", required_points: 5 }]
      ))
      expect(point_card.rewards).to be_empty
    end

    # すべて入力あり
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