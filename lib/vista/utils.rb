require 'mongo'
module Vista
  module Utils
    include Mongo

    def coll(name)
      db[name]
    end

    def self.mongodb
      return @mongo_db if @mongo_db
      mongo_client =
      if ENV['MONGOHQ_URL']
        db = URI.parse(ENV['MONGOHQ_URL'])
        db_name = db.path.gsub(/^\//, '')
        db_connection = Mongo::Connection.new(db.host, db.port).db(db_name)
        db_connection.authenticate(db.user, db.password) unless (db.user.nil? || db.user.nil?)
        db_connection
      else
        MongoClient.new
      end
      @mongo_db = mongo_client
      @mongo_db
    end

    def mongodb
      Utils.mongodb
    end

    def db
      mongodb['vista']
    end

    def inflate_photo(vista_id, photo_id)
      vpu = VistaPhotoUploader.new
      # string
      vpu.vista_id = vista_id.to_s
      vpu.retrieve_from_store!(photo_id)
      thumb = vpu.thumb
      thumb.retrieve_from_store!(photo_id)
      return {
        thumb: thumb,
        main: vpu,
        id: photo_id
      }
    end

    def inflate_photos(vista_id, photos)
      ret = []
      photos.each do |photo|
        ph = inflate_photo(vista_id, photo['photo_id'])
        ret.push({
          id: ph[:id],
          url: ph[:main].url,
          thumb: ph[:thumb].url
        })
      end
      return ret
    end
  end
end
