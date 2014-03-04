module Vista
  # Admin utilities for Vista
  class Admin
    DEFAULT_EMAIL = "mike@mikec.me"
    class << self
      def upload_photo(vista_id, file, user = nil)
        unless user
          user = ::User.find_by(email: DEFAULT_EMAIL)
        end
        vpu = VistaPhotoUploader.new
        vpu.current_user = user
        vpu.vista_id = vista_id
        vpu.store_with_thumb(file)
        user_email = user.email
        photo_id = vpu.identifier
        Vista::Vistas.add_photo(BSON::ObjectId(vista_id), user_email, photo_id)
      end
    end
  end
end
