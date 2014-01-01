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

  def stats_for_area(area_name)
    return Vista::User.stats_area(email, area_name)
  end

  def profile_stats
    return Vista::User.profile_stats(email)
  end
end
