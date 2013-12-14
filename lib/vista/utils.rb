require 'mongo'
module Utils
  include Mongo

  def coll(name)
    db[name]
  end

  def self.mongodb
    @mongo_client ||= MongoClient.new
  end

  def mongodb
    Utils.mongodb
  end

  def db
    mongodb['vista']
  end
end
