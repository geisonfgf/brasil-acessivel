class SiteController < ApplicationController
  before_action :set_markers, only: [:index]

  def index
    if params[:address].nil?
      @map_zoom = 4
      @map_central_cooordinates = Geocoder.coordinates("Brasil")
    else
      @map_zoom = 12
      @map_central_cooordinates = Geocoder.coordinates(params[:address])
    end
  end

  private

    def set_places_near_by
      @places = Place.all
      params[:address].nil? ? address = 'Brasil' : address = params[:address]
      if address == 'Brasil'
        @places_near = @places.near(address, 7500, :unit => :km)
      else
        @places_near = @places.near(address, 20, :unit => :km)
      end
    end

    def set_markers
      set_places_near_by
      image_marker = {
        :url => view_context.image_path("map_marker.png"),
        :width =>  50,
        :height => 50
      }
      @markers = Gmaps4rails.build_markers(@places_near) do |place, marker|
        acessibility_level = ("<span><img src='" + view_context.image_path("ico_cadeira_rodas.png") + "' /></span>") * place.rating
        marker.picture image_marker
        marker.infowindow "<h4>#{place.name}</h4><h5><span>Acessibilidade:</span> #{acessibility_level}</h5><p>#{place.description}</p>"
        marker.lat place.latitude
        marker.lng place.longitude
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:address)
    end
end
