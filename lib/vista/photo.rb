module Vista
  class Photo
    extend Utils
    class << self
      def all_unapproved
        coll('vistas').find({ 'photos.0' => {'$exists' => 1}, 'photos.approved' => false}, fields: ['_id', 'photos'])
      end

      def all
        coll('vistas').find({ 'photos.0' => {'$exists' => 1}}, fields: ['_id', 'photos'])
      end

      def remove(photo_id)
        #TODO: remove visit too
        coll('vistas').find({ 'photos.photo_id' =>  photo_id }).each do |vista|
          remove_photo(vista['_id'], photo_id)
        end
        coll('vistas').update({}, { '$pull' => { 'photos' => { 'photo_id' => photo_id } } }, multi: true)
      end

      def set_approved(photo_id, approved = true)
        coll('vistas').update({ 'photos.photo_id' => photo_id }, { '$set' => { 'photos.$.approved' => approved } })
      end
    end
  end
end
