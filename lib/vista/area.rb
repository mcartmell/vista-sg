require 'polylines'

module Vista
  class Area
    extend Utils
    STATIC_MAP_WIDTH=200
    STATIC_MAP_HEIGHT=160

    def self.static_map(area_name)
      area = coll('areas').find_one(name: area_name, size: 2)
      polys = area['geometry']['coordinates'].map do |poly|
        poly.map do |pair|
          pair = [pair[1], pair[0]]
        end
      end

      encoded = polys.map {|p| Polylines::Encoder.encode_points(p) }
      first_poly = encoded.first
      url = "http://maps.googleapis.com/maps/api/staticmap?sensor=false&size=#{STATIC_MAP_WIDTH}x#{STATIC_MAP_HEIGHT}&path=fillcolor:0xAA000033%7Ccolor:0xFFFFFF00%7Cenc:#{first_poly}"
      return url
    end

    def self.list
      coll('areas').find()
    end

    def self.remove_vista(vista_id)
      v = coll('vistas').find_one(vista_id)
      lat = v['geometry']['coordinates'][1]
      lat = v['geometry']['coordinates'][0]

      # remove from vista table
      coll('vistas').remove({ _id: vista_id })

      # remove from areas
      coll('areas').update({
      },
      {
        '$pull' => {
          vistas: vista_id
        }
      },
      {
        multi: true
      })
    end

    # Find vistas and details for a given area name. Note that one area name
    # can have multiple polygon areas (eg. to include islands)
    #
    # This can be cached btw
    def self.find_vistas(area_name, opts = {})
      Rails.cache.fetch("vistas_for_#{area_name}", expires_in: 5.minutes) { _find_vistas(area_name, opts) }
    end

    def self._find_vistas(area_name, opts)
      all_vistas = []
      opts = { name: area_name }.merge(opts)
      coll('areas').find(
        opts
      ).each do |area|
        all_vistas.push(Vista::Vistas.find_vistas(area['vistas']))
      end
      return all_vistas.flatten
    end

    def self.all_vistas_by_area_detailed
      return _all_vistas_by_area_detailed
    end

    def self._all_vistas_by_area_detailed
      area_vistas = {}
      all_areas = coll('areas').find({ size: 2 }).to_a.map {|a| a['name']}.uniq
      all_areas.each do |name|
        area_vistas[name] ||= []
        area_vistas[name] += _find_vistas(name, size: 2)
      end
      return area_vistas
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
      res = coll('vistas').update(
        {
          name: name,
        },
        {
          name: name,
          geometry: {
            type: 'Point',
            coordinates: [long, lat]
          },
          description: description,
          directions: directions
        },
        {
          upsert: true
        }
      )
      return if res['updatedExisting']
      vista_id = res['upserted']
      Vista::Geo.new.find_places_for_coords(lat, long).each do |area|
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
      return true
    end

    # Run this when vista locations or area boundaries have been updated
    # Will clear vistas array for every area and repopulate it from geography.
    # When adding and removing vistas normally this isn't required.
    def self.recalculate_area_vistas
      coll('areas').find.each do |area|
        area_vistas = coll('vistas').find({
          geometry: {
            '$geoWithin' => {
              '$geometry' => area['geometry']
            }
          }
        }, {:fields => [:_id]}).to_a.map{|v| v['_id']}

        next if area_vistas.empty?
        puts "Updating #{area['name']} to #{area_vistas.inspect}"
        coll('areas').update({
          _id: area['_id']
        },
        {
          '$set' => {
            'vistas' => area_vistas
          }
        })
      end
    end
  end
end
