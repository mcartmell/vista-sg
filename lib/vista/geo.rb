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
        vistas: Vista::Area.find_vistas(area['name'])
      }
    end
  end
end
