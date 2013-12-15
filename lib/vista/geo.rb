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
  end
end
