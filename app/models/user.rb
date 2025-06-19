class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :default_point_card, class_name: 'PointCard', optional: true

  has_many :given_point_cards, class_name: 'PointCard', foreign_key: 'giver_id', dependent: :destroy
  has_many :received_point_cards, class_name: 'PointCard', foreign_key: 'receiver_id', dependent: :destroy
  has_many :point_records, foreign_key: 'added_by_user_id', dependent: :destroy
  has_many :notifications, dependent: :destroy

  validates :name, presence: true
end
