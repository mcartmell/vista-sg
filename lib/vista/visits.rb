module Vista
  class Visits < MongoObject
    extend Utils
    class << self
      def table_name
        'visits'
      end

      def create (user_email, vista_id)
        coll('visits').update({ email: user_email, vista_id: vista_id }, { email: user_email, vista_id: vista_id, date: Time.now }, { upsert: true })
      end

      def remove(user_email, vista_id)
        coll('visits').remove({ email: user_email, vista_id: vista_id })
      end
    end
  end
end
