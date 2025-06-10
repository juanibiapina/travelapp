json.extract! place, :id, :name, :trip_id, :created_at, :updated_at
json.url trip_place_url(@trip, place, format: :json)
