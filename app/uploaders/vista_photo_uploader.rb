# encoding: utf-8
require 'uuid'

class VistaPhotoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MimeTypes
  include CarrierWave::RMagick

  attr_accessor :current_user, :vista_id, :name

  process :fix_exif_rotation
  process :set_content_type

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{current_user.id}/#{vista_id}/"
  end

  def thumb
    thumb = VistaThumbUploader.new
    thumb.current_user = current_user
    thumb.vista_id = vista_id
    thumb.name = name
    return thumb
  end

  def store_thumb!(file)
    thumb.store!(file)
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  def filename
    @name ||= "#{uuid}.jpg"
  end

  def store_with_thumb(file)
    store!(file)
    store_thumb!(file)
  end

  protected

  def uuid
    UUID.state_file = false
    uuid = UUID.new
    uuid.generate
  end

end

class VistaThumbUploader < VistaPhotoUploader
  process :resize_to_fill => [120, 120]

  def store_dir
    "uploads/#{current_user.id}/#{vista_id}/thumbs/"
  end
end

