class CreatePointCards < ActiveRecord::Migration[8.0]
  def change
    create_table :point_cards do |t|
      t.references :giver, null: false, foreign_key: { to_table: :users }
      t.references :receiver, foreign_key: { to_table: :users }
      t.string :title, null: false
      t.text :message
      t.string :pin_code
      t.integer :max_point, default: 20, null: false
      t.integer :current_round, default: 1, null: false

      t.timestamps
    end
  end
end
