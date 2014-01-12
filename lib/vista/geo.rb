module Vista
  class Geo
    include Vista::Utils
    
    def find_places_for_coords(lat, lon)
      return coll('areas').find( geometry:
          { "$geoIntersects" =>
              { "$geometry" =>
                  { type: "Point", coordinates: [lon, lat] }
              }
          }
      ).to_a
    end

    def find_smallest_place_for_coords(*a)
      all = find_places_for_coords(*a)
      return all.max_by{|x| x['size']}
    end

    def current_area(lat, lon)
      area = find_places_for_coords(lat, lon).find{|e| e['size'] == 2}
      return area
    end

    def find_vistas_for_point(lat, lon)
      area = current_area(lat, lon)
      # Find area
      return {
        area: area,
        vistas: Vista::Area.find_vistas({ area_name: area['name'] })
      }
    end

    def self.haversine(lat1, long1, lat2, long2)
      dtor = Math::PI/180
      r = 6378.14
     
      rlat1 = lat1 * dtor 
      rlong1 = long1 * dtor 
      rlat2 = lat2 * dtor 
      rlong2 = long2 * dtor 
     
      dlon = rlong1 - rlong2
      dlat = rlat1 - rlat2
     
      a = (Math::sin(dlat/2) ** 2) + Math::cos(rlat1) * Math::cos(rlat2) * (Math::sin(dlon/2) ** 2)
      c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
      d = r * c
     
      return d.round(2)
    end
  end
end
