require 'set'

module Vista
  class User
    extend Vista::Utils

    def self.find(email)
      coll('users').find_one({ email: email })
    end

    def self.profile_stats(email)
      user = find(email)
      user['visits'] ||= []

      stats = stats_total(email)
      areas_completed = stats.select {|a| a['pct'] == 100}
      total_areas = stats.size
      total_vistas = stats.map{|a| a[:total]}.inject{|sum,x| sum + x}
      ret = user.merge({
        areas: stats.sort_by{|s| s[:area_name]},
        areas_completed: areas_completed,
        total_areas_completed: areas_completed.count,
        total_areas: total_areas,
        total_vistas: total_vistas,
        total_visits: user['visits'].count
      })
    end

    def self.visited?(email, vista_id)
      visits = visits(email)
      return visits.any? {|vista| vista == vista_id}
    end

    def self.stats_area(email, area_name)
      visits = Set.new visits(email)
      area_vistas = Set.new Vista::Area.find_vistas(area_name).map {|v| v['_id']}
      total = area_vistas.size
      visited = visits & area_vistas
      num_visited = visited.count
      return {
        visited: num_visited,
        total: total
      }
    end

    def self.visits(email)
      user = coll('users').find_one({ email: email })
      return [] unless user
      return user['visits'] || []
    end

    # Return statistics on vistas achieved by area
    def self.stats_total(email)
      all_areas = Vista::Area.all_vistas_by_area
      user = find(email)
      user_vistas = {}
      user['visits'] ||= []
      user['visits'].each {|v| user_vistas[v.to_s] = 1}
      stats = []
      all_areas.each do |area, v|
        total_vistas = v.size
        visited = v.select {|v| user_vistas[v.to_s]}
        total_visited = visited.size
        stats.push(
        {
          area_name: area,
          visited: total_visited,
          total: total_vistas,
          pct: total_vistas > 0 ? (total_visited / total_vistas.to_f).round(2) : nil
        })
      end
      return stats.sort_by {|s| s[:area_name]}
    end

    def self.get_photos_for_vista(email, vista_id)
      vistas = coll('vistas').find({
        "_id" => vista_id,
        "photos.user_email" => email
      },
      {
        :fields => [:photos]
      })
      return [] if vistas.count == 0
      photos = vistas.first['photos'].select{|p| p['user_email'] == email}
      return inflate_photos(vista_id, photos)
    end

    def self.add_visit(email, vista_id)
        coll('users').update({
          email: email
        },
          {
            '$addToSet' =>
            {
              'visits' => vista_id
            }
          },
          {
            upsert: true
          }
        )
    end
  end
end
