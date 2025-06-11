class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :point_card

  validates :content, presence: true
end
