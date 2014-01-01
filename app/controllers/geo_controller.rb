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
    if params.has_key?(:lat) && params.has_key?(:lon)
      lat = params[:lat].to_f
      lon = params[:lon].to_f
      vg = Vista::Geo.new
      res = vg.find_vistas_for_point(lat, lon)
      return render json: res
    elsif params.has_key?(:area_name)
      vistas = Vista::Area.find_vistas(params[:area_name])
      stats = current_user.stats_for_area(params[:area_name])
      res = { 
        vistas: vistas
      }.merge(stats)
      return render json: res
    else
      raise "Invalid params"
    end
  end
end
