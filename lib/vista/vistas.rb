module Vista
  class Vistas
    extend Utils

    def self.find(vista_id)
      coll('vistas').find({
        _id: vista_id
      }).first
    end

    def self.find_vistas(vista_ids)
      return [] unless vista_ids
      coll('vistas').find({
        _id: {'$in' => vista_ids}
      }).to_a
    end
  end
end
