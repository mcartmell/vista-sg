class GeoController < ApplicationController
  respond_to :json

  def whereami
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    logger.info(params)
    vg = Vista::Geo.new
    places = vg.find_places_for_coords(lat, lon).sort_by{|p| p['size']}
    region = places[0]
    area = places[1]
    subzone = places[2]

    res = {
      subzone: {
        name: (subzone['name'] rescue 'Unknown')
      },
      area: {
        name: (area['name'] rescue 'Unknown')
      },
      region: {
        region: (region['name'] rescue 'Unknown')
      },
    }
    render json: res
  end

  def find_vistas
    lat = params[:lat].to_f
    lon = params[:lon].to_f
    vg = Vista::Geo.new
    res = vg.find_vistas_for_point(lat, lon)
    logger.info(res)
    render json: res
  end

end
