class AddDatesToPlaces < ActiveRecord::Migration[8.0]
  def change
    add_column :places, :start_date, :date, null: false
    add_column :places, :end_date, :date, null: false
  end
end
