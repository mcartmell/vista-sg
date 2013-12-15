class Admin::VistasController < ApplicationController
  before_filter :authenticate_admin!

  def list
    @vistas = Vista::Area.all_vistas_by_area_detailed
  end

  def new
  end

  def create
    Vista::Area.add_vista(
      params[:name],
      params[:lat].to_f,
      params[:lon].to_f,
      params[:description],
      params[:directions])
    redirect_to action: 'list'
  end

  def remove
    id = BSON::ObjectId(params[:id])
    Vista::Area.remove_vista(id)
    redirect_to action: 'list'
  end
end
