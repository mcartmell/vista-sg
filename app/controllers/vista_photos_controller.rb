class VistaPhotosController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    photo = params[:file]
    vista_id = params[:vista_id]
    uploader = VistaPhotoUploader.new
    uploader.current_user = current_user
    uploader.vista_id = vista_id

    # thumbnail
    res = uploader.store_with_thumb(photo)

    # Add photo and add to user visits
    user_email = current_user.email
    photo_id = uploader.identifier
    Vista::Vistas.add_photo(BSON::ObjectId(vista_id), user_email, photo_id)
    Vista::User.add_visit(user_email, BSON::ObjectId(vista_id))
    render json: { success: true }
  end

  def list_user
    vista_id = params[:vista_id]
    photos = current_user.list_photos_for_vista(BSON::ObjectId(vista_id))
    render json: {
      photos: photos
    }
  end
end
