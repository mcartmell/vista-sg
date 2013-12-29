module Vista
  class Vistas
    extend Utils

    def self.find(vista_id)
      vista = coll('vistas').find({
        _id: vista_id
      }).first
    end

    def self.find_vistas(vista_ids)
      return [] unless vista_ids
      coll('vistas').find({
        _id: {'$in' => vista_ids}
      }).to_a
    end

    def self.add_photo(vista_id, user_email, photo_id, approved = false)
      coll('vistas').update({ _id: vista_id },
        {
          "$push" => {
            photos: {
              user_email: user_email,
              photo_id: photo_id,
              approved: approved
            }
          }
        })
    end
  end
end
