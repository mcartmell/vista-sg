require 'json'
require 'mongo'
include Mongo
client = MongoClient.new
db = client['vista']

types = {
  'areas_l' => {key: 'REGION_N'},
  'areas_m' => {key: 'PLN_AREA_N', parent_key: 'REGION_N'},
  'areas_sm' => {key: 'SUBZONE_N', parent_key: 'PLN_AREA_N'}
}

types.each do |size, v|
  # initialize collection
  coll = db[size.to_s]
  coll.drop
  coll.ensure_index([[:geometry, Mongo::GEO2DSPHERE]])

  fn = File.dirname(__FILE__) + "/../data/geo/#{size}.geojson"
  j = JSON.load(File.open(fn, 'r'))
  name_key = v[:key]
  j['features'].each do |area|
    area_name = area['properties'][name_key].split(/ /).map{|s| s.capitalize}.join(' ')
    parent_name = area['properties'][parent_key].split(/ /).map{|s| s.capitalize}.join(' ') rescue nil
    #area['geometry']['coordinates'][0].uniq! {|e| "#{e[0]}_#{e[1]}"}
    coords = area['geometry']
    if coords['type'] == 'MultiPolygon'
      coords['coordinates'].each_with_index do |poly, i|
        coords = {
          type: 'Polygon',
          coordinates: poly
        }
        begin
          coll.insert({
            name: area_name,
            geometry: coords,
            parent: parent_name,
            poly: i
          })
        rescue StandardError => e
          puts "Fail #{size} #{area_name} #{i}:#{e.message[0..200]}...\n\n#{coords.to_json}\n\n"
        end
      end
    else 
      begin
        coll.insert({
          name: area_name,
          geometry: coords,
          parent: parent_name
        })
      rescue StandardError => e
        puts "Fail #{size} #{area_name}:#{e.message[0..200]}"
      end
    end
  end
end

