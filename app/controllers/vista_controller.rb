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
    res = uploader.store!(photo)
    render json: res
  end
end
