class CreateSpecialDays < ActiveRecord::Migration[8.0]
  def change
    create_table :special_days do |t|
      t.references :point_card, null: false, foreign_key: true
      t.integer :date, null: false
      t.integer :multiplier, null: false, default: 2

      t.timestamps
    end
  end
end
