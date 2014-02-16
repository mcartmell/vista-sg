class Admin::VistasController < ApplicationController
  before_filter :authenticate_admin!
  skip_before_filter :authenticate_user!

  include Vista::Utils

  def list
    @vistas = Vista::Area.all_vistas_by_area_detailed
  end

  def new
  end

  def create
    lat, lon = params[:lat_lon].split(%r{,\s*}).map(&:to_f)
    Vista::Area.add_vista(
      params[:name],
      lat,
      lon,
      params[:description],
      params[:directions])
    redirect_to action: 'list'
  end

  def show
    id = BSON::ObjectId(params[:id])
    @vista = Vista::Vistas.find(id)
    @photos = Vista::Vistas.list_photos(id)
    logger.info(@photos)
  end

  def update
    id = BSON::ObjectId(params[:id])
    set_params = params.slice(:description, :directions, :name, :default_photo)
    coll('vistas').update({
      _id: id
    },
    {
      '$set' => set_params
    }
    )
    redirect_to action: :list
  end

  def remove
    id = BSON::ObjectId(params[:id])
    Vista::Area.remove_vista(id)
    redirect_to action: 'list'
  end
end
