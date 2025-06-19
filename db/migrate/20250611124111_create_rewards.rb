class CreateRewards < ActiveRecord::Migration[8.0]
  def change
    create_table :rewards do |t|
      t.references :point_card, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :required_points, null: false
      t.text :message

      t.timestamps
    end
  end
end
