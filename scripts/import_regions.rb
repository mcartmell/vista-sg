require 'json'
require 'mongo'
include Mongo
client = Vista::Utils.mongodb
db = client['vista']

types = {
  'areas_l' => {key: 'REGION_N', size: 1},
  'areas_m' => {key: 'PLN_AREA_N', parent_key: 'REGION_N', size: 2},
  'areas_sm' => {key: 'SUBZONE_N', parent_key: 'PLN_AREA_N', size: 3}
}


coll = db['areas']
coll.ensure_index([[:geometry, Mongo::GEO2DSPHERE]])
coll.ensure_index([:name])

coll = db['users']
coll.ensure_index([:email])

coll = db['vistas']
coll.ensure_index([[:geometry, Mongo::GEO2DSPHERE]])
import_areas = false

if import_areas
  coll.drop
  types.each do |size, v|
    # initialize collection

    fn = File.dirname(__FILE__) + "/../data/geo/#{size}.geojson"
    j = JSON.load(File.open(fn, 'r'))
    name_key = v[:key]
    parent_key = v[:parent_key]
    j['features'].each do |area|
      area_name = area['properties'][name_key].split(/ /).map{|s| s.capitalize}.join(' ')
      parent_name = area['properties'][parent_key].split(/ /).map{|s| s.capitalize}.join(' ') rescue nil
      #area['geometry']['coordinates'][0].uniq! {|e| "#{e[0]}_#{e[1]}"}
      coords = area['geometry']
      defaults = {
        name: area_name,
        parent: parent_name,
        size: v[:size]
      }

      if coords['type'] == 'MultiPolygon'
        coords['coordinates'].each_with_index do |poly, i|
          coords = {
            type: 'Polygon',
            coordinates: poly
          }
          begin
            coll.insert(defaults.merge({
              geometry: coords,
              poly: i
            }))
          rescue StandardError => e
            puts "Fail #{size} #{area_name} #{i}:#{e.message[0..200]}...\n\n#{coords.to_json}\n\n"
          end
        end
      else 
        begin
          coll.insert(defaults.merge({
            geometry: coords
          }))
        rescue StandardError => e
          puts "Fail #{size} #{area_name}:#{e.message[0..200]}"
        end
      end
    end
  end
end


