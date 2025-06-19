class AddDatesToPlaces < ActiveRecord::Migration[8.0]
  def change
    # Add columns as nullable first
    add_column :places, :start_date, :date
    add_column :places, :end_date, :date

    # Update existing places to use their trip's dates
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE places#{' '}
          SET start_date = trips.start_date, end_date = trips.end_date
          FROM trips#{' '}
          WHERE places.trip_id = trips.id
        SQL
      end
    end

    # Now make the columns non-nullable
    change_column_null :places, :start_date, false
    change_column_null :places, :end_date, false
  end
end
