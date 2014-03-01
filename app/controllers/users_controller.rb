class UsersController < ApplicationController
  respond_to :json

  def profile
    ret = current_user.profile_stats.merge({ user: current_user.attributes.slice(*%w{username email})})
    render json: ret
  end

  def area_stats
    ret = {
      areas: current_user.area_stats
    }
    render json: ret
  end
end
