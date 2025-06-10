class CreatePlaces < ActiveRecord::Migration[8.0]
  def change
    create_table :places do |t|
      t.string :name
      t.references :trip, null: false, foreign_key: true

      t.timestamps
    end
  end
end
