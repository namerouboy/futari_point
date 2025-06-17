class PointRecord < ApplicationRecord
  belongs_to :point_card
  belongs_to :added_by_user, class_name: 'User'

  after_create_commit :check_reward

  validates :points, numericality: { greater_than: 0 }


  private

  def check_reward
    if point_card.current_points % 20 == 0
      notification = Notification.create!(
        user:       point_card.giver,
        point_card: point_card,
        content:    "ポイントカードが満タンになりました！"
      )

  elsif (reward = point_card.rewards.find_by(required_points: point_card.current_points % 20))
    Notification.create!(
      user:       point_card.giver,
      point_card: point_card,
      content:    reward.message
    )
  end
end

end
