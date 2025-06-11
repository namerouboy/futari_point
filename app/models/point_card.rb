class PointCard < ApplicationRecord
  belongs_to :giver, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  has_many :point_records, dependent: :destroy
  has_many :special_days, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :rewards, dependent: :destroy

  validates :title, presence: true
  validates :max_point, numericality: { greater_than: 0 }
  validates :current_round, numericality: { greater_than: 0 }
end
