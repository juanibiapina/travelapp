json.extract! place, :id, :name, :start_date, :end_date, :trip_id, :created_at, :updated_at
json.url trip_place_url(@trip, place, format: :json)
