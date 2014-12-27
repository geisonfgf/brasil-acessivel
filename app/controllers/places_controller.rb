class PlacesController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_place, only: [:edit, :update, :destroy]
  before_action :set_markers, only: [:show]

  # GET /places
  # GET /places.json
  def index
    @places = Place.all
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Local salvo com sucesso!' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Local atualizado com sucesso!' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Local deletado com sucesso!' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    def set_places_near_by
      set_place
      @places_near = @place.nearbys(2)
    end

    def set_markers
      set_places_near_by
      places = @places_near
      places << @place
      image_marker = {
        :url => view_context.image_path("map_marker.png"),
        :width =>  50,
        :height => 50
      }
      @markers = Gmaps4rails.build_markers(places) do |place, marker|
        marker.picture image_marker
        marker.infowindow "<h5>#{place.name}</h5><p>#{place.description}</p>"
        marker.lat place.latitude
        marker.lng place.longitude
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:name, :description, :rating, :latitude, :longitude, :address)
    end
end
