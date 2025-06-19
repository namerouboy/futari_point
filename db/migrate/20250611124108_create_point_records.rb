class CreatePointRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :point_records do |t|
      t.references :point_card, null: false, foreign_key: true
      t.references :added_by_user, null: false, foreign_key: { to_table: :users }
      t.integer :points, default: 1, null: false

      t.timestamps
    end
  end
end
