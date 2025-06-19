class PointCard < ApplicationRecord
  belongs_to :giver, class_name: 'User'
  belongs_to :receiver, class_name: 'User', optional: true

  before_create :regenerate_pin_code

  has_many :point_records, dependent: :destroy
  has_many :special_days, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :rewards, dependent: :destroy

  # SpecialDayとごほうびの設定入力時の制御
  accepts_nested_attributes_for :special_days,
    allow_destroy: true,
    reject_if: ->(attr) { attr['date'].blank? }

  accepts_nested_attributes_for :rewards,
    allow_destroy: true,
    reject_if: ->(attr) { attr['required_points'].blank? || attr['message'].blank? || attr['name'].blank? }

  validates :title, presence: true
  validates :max_point, numericality: { greater_than: 0 }
  validates :current_round, numericality: { greater_than: 0 }

  #現在の所持ポイント
  def current_points
    point_records.sum(:points)
  end

  #スタンプ満タンかどうかのチェック
  def full?
    current_points % 20 == 0 && current_points != 0
  end

  #ご褒美達成ポイントかどうかのチェック
  def reached_reward
    rewards.find_by(required_points: current_points % 20)
  end

  private

  #PINコード作成
  def regenerate_pin_code
    self.pin_code = SecureRandom.hex(3).upcase  # 例: 6桁の英数字PIN
  end
end
