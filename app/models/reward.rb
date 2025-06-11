class Reward < ApplicationRecord
  belongs_to :point_card

  validates :name, presence: true
  validates :required_points, numericality: { greater_than: 0 }
end
