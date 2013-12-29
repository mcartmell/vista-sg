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

    def inflate_photos(vista_id, photos)
      ret = []
      photos.each do |photo|
        vpu = VistaPhotoUploader.new
        email = photo['user_email']
        vpu.current_user = ::User.find_by(email: email)
        # string
        vpu.vista_id = vista_id.to_s
        vpu.retrieve_from_store!(photo['photo_id'])
        thumb = vpu.thumb
        thumb.retrieve_from_store!(photo['photo_id'])
        ret.push({
          url: vpu.url,
          thumb: thumb.url
        })
      end
      return ret
    end
  end
end
