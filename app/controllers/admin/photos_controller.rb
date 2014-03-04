class Admin::PhotosController < ApplicationController
  before_filter :authenticate_admin!
  skip_before_filter :authenticate_user!
  def create
    vista_id = params[:vista_id]
    file = params[:file]
    Vista::Admin.upload_photo(vista_id, file)
    redirect_to '/admin/photos'
  end

  def new
    @vistas = Vista::Vistas.list
    @vistas_select = @vistas.map {|v| [v['name'], v['_id'].to_s]}.sort_by{|v| v[0]}
  end

  def index
    @photos = {}
    #TODO: change to all_unapproved
    Vista::Photo.all.each do |photo|
      @photos[photo['_id'].to_s] = photo['photos']
    end
  end

  def destroy
    photo_id = params[:id] + '.jpg'
    Vista::Photo.remove(photo_id)
    redirect_to action: :index
  end

  def approve
    photo_id = params[:id] + '.jpg'
    Vista::Photo.set_approved(photo_id, true)
    redirect_to action: :index
  end

  def unapprove
    photo_id = params[:id] + '.jpg'
    Vista::Photo.set_approved(photo_id, false)
    redirect_to action: :index
  end
end
