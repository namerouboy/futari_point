class PointCard < ApplicationRecord
  belongs_to :giver, class_name: 'User'
  belongs_to :receiver, class_name: 'User', optional: true

  before_create :regenerate_pin_code

  has_many :point_records, dependent: :destroy
  has_many :special_days, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :rewards, dependent: :destroy

  accepts_nested_attributes_for :special_days,
                                allow_destroy: true,
                                reject_if: ->(att) { att['day'].blank? || att['multiplier'].blank? }

  accepts_nested_attributes_for :rewards,
                                allow_destroy: true,
                                reject_if: ->(att) { att['required_points'].blank? || att['message'].blank? }

  validates :title, presence: true
  validates :max_point, numericality: { greater_than: 0 }
  validates :current_round, numericality: { greater_than: 0 }

  def current_points
    point_records.sum(:points)
  end

  private

  def regenerate_pin_code
    self.pin_code = SecureRandom.hex(3).upcase  # 例: 6桁の英数字PIN
  end
end
