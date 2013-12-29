class VistaController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token

  def vista_details
    vista_id = BSON::ObjectId(params[:vista_id])
    vista = Vista::Vistas.find(vista_id)
    render json: vista
  end

  def upload_photo
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
    Vista::Vistas.add_photo(vista_id, user_email, photo_id)
    Vista::User.add_visit(user_email, vista_id)
    render json: { success: true }
  end
end
