class User < ActiveRecord::Base
  acts_as_token_authenticatable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def list_photos_for_vista(vista_id)
    return Vista::User.get_photos_for_vista(email, vista_id)
  end

  def get_latest_photo_for_vista(vista_id)
    return list_photos_for_vista(vista_id).last
  end

  def visited?(vista_id)
    return Vista::User.visited?(email, vista_id)
  end

  def visits
    return Vista::User.visits(email)
  end

  # stats for a single area
  def stats_for_area(area_name)
    return Vista::User.stats_area(email, area_name)
  end

  # summary of stats for all areas
  def profile_stats
    return Vista::User.profile_stats(email)
  end

  # stats by area
  def area_stats
    return Vista::User.stats_total(email)
  end
end
