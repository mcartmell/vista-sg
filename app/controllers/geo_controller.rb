class GeoController < ApplicationController
  respond_to :json
  def whereami
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    vg = Geo.new
    place = vg.find_smallest_place_for_coords(lat, lon)
    r = {
      name: place['name']
    }
    render json: r
  end
end
