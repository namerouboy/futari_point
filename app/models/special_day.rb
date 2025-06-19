class SpecialDay < ApplicationRecord
  belongs_to :point_card

  validates :date, presence: true
  validates :multiplier, numericality: { greater_than: 1 }
end
