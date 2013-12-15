module Vista
  class Area
    extend Utils

    def self.remove_vista(vista_id)
      # remove from vista table
      coll('vistas').remove({ _id: vista_id })

      # remove from areas
      Vista::Geo.new.find_places_for_coords(lat, long).each do |area|
        coll('areas').update({
          _id: area['_id']
        },
        {
          '$pull' => {
            vistas: vista_id
          }
        })
      end
    end

    # Find vistas and details for a given area name. Note that one area name
    # can have multiple polygon areas (eg. to include islands)
    #
    # This can be cached btw
    def self.find_vistas(area_name)
      Rails.cache.fetch("vistas_for_#{area_name}", expires_in: 5.minutes) { _find_vistas(area_name) }
    end

    def self._find_vistas(area_name)
      all_vistas = []
      coll('areas').find({
        name: area_name
      }).each do |area|
        all_vistas.push(Vista::Vistas.find_vistas(area['vistas']))
      end
      return all_vistas.flatten
    end

    # Return a list of all the vista ids keyed by area. This can be cached too.
    def self.all_vistas_by_area
      Rails.cache.fetch('vistas_by_area', expires_in: 5.minutes) { _all_vistas_by_area }
    end

    def self._all_vistas_by_area
      area_vistas = {}
      coll('areas').find({ size: 2 }).each do |area|
        area_vistas[area['name']] ||= []
        area_vistas[area['name']] += area['vistas'] || []
      end
      area_vistas.values.each(&:uniq!)
      return area_vistas
    end

    def self.add_vista(name, lat, long, description = '', directions = '')
      vista_id = coll('vistas').insert({
        name: name,
        geometry: {
          type: 'Point',
          coordinates: [long, lat]
        },
        description: description,
        directions: directions
      })
      Vista::Geo.new.find_places_for_coords(lat, long).each do |area|
        puts area['_id']
        puts area['name']
        coll('areas').update({
          _id: area['_id']
        },
          {
            '$addToSet' =>
            {
              'vistas' => vista_id
            }
          }
        )
      end
      true
    end
  end
end
