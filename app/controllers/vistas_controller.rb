class VistasController < ApplicationController
  respond_to :json
  skip_before_filter :verify_authenticity_token

  def show
    vista_id = BSON::ObjectId(params[:id])
    vista = Vista::Vistas.find(vista_id)
    vista['visited'] = current_user.visited?(vista_id)
    render json: vista
  end
end
