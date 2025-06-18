class PointRecord < ApplicationRecord
  belongs_to :point_card
  belongs_to :added_by_user, class_name: 'User'

  after_create_commit :check_reward

  validates :points, numericality: { greater_than: 0 }


  private

  #ごほうび達成なら通知
  def check_reward
    before  = point_card.current_points - points
    after   = point_card.current_points
    ids     = []

    points.times do |i|
      n = (before + i + 1) % 20
      n = 20 if n.zero?        # 0 → 20 に置き換え
      ids << n
    end
    ids.uniq!                 # 重複を除去

    # --- ごほうび通知 ---
    point_card.rewards.where(required_points: ids).find_each do |reward|
      Notification.create!(
        user:        point_card.giver,
        point_card:  point_card,
        content:     reward.message
      )
    end

    # --- 満タン通知 ---
    if ids.include?(20)
      Notification.create!(
        user:        point_card.giver,
        point_card:  point_card,
        content:     "ポイントが満タンになりました！"
      )
    end
  end
end
