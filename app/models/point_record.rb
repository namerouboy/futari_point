class PointRecord < ApplicationRecord
  belongs_to :point_card
  belongs_to :added_by_user, class_name: 'User'

  validates :points, numericality: { greater_than: 0 }
end
