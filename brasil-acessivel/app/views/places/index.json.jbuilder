json.array!(@places) do |place|
  json.extract! place, :id, :name, :description, :rating, :latitude, :longitude, :address
  json.url place_url(place, format: :json)
end
