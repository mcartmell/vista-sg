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
    res = {}
    lat = params[:lat] ? params[:lat].to_f : nil
    lon = params[:lon] ? params[:lon].to_f : nil
    if params.has_key?(:area_name)
      args = {
        area_name: params[:area_name]
      }
      if lat && lon
        args[:lat] = lat
        args[:lon] = lon
      end
      vistas = Vista::Area.find_vistas(args)
      if vistas.size > 0 && vistas[0][:dis]
        vistas = vistas.sort_by {|v| v[:dis].to_f}
      end
      stats = current_user.stats_for_area(params[:area_name])
      res = { 
        vistas: vistas
      }.merge(stats)
    elsif lat && lon
      vg = Vista::Geo.new
      res = vg.find_vistas_for_point(lat, lon)
    else
      raise "Invalid params"
    end

    area_name = res['area'] ? res['area']['name'] : params[:area_name]
    static_map_url = Vista::Area.static_map(area_name)
    res.merge!(static_map: static_map_url)

    render json: res
  end
end
