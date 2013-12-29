module Vista
  class User
    extend Vista::Utils

    def self.visited?(email, vista_id)
      user = coll('users').find_one({ email: email })
      visits = user['visits'] || []
      return visits.any? {|vista| vista == vista_id}
    end

    # Return statistics on vistas achieved by area
    def self.stats_total(user_id)
      all_areas = Vista::Area.all_vistas_by_area
      user = coll('users').find_one(_id: user_id)
      user_vistas = {}
      user['vistas'].each {|v| user_vistas[v.to_s] = 1}
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
      return stats
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
      photos = vistas.first['photos']
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
