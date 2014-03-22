module Vista
  class MongoObject
    extend Utils
    class << self
      def where(args = {})
        coll(table_name).find(args)
      end

      def insert(*args)
        coll(table_name).insert(args)
      end
    end
  end
end
