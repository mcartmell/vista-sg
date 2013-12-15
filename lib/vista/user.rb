module Vista
  class User
    extend Vista::Utils

    # Return statistics on vistas achieved by area
    def self.stats_total(user_id)
      all_areas = Vista::Area.all_vistas_by_area
      user = coll('users').find_one(_id: user_id)
      user_vistas = {}
      user['vistas'].each {|v| user_vistas[v.to_s] = 1}
      stats = {}
      all_areas.each do |area, v|
        total_vistas = v.size
        visited = v.select {|v| user_vistas[v.to_s]}
        total_visited = visited.size
        stats[area] =
        {
          visited: total_visited,
          total: total_vistas,
          pct: total_vistas > 0 ? (total_visited / total_vistas.to_f).round(2) : nil
        }
      end
      return stats
    end
  end
end
