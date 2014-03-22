module Vista
  class Vistas
    extend Utils

    def self.list
      coll('vistas').find
    end

    def self.find(vista_id)
      vista = coll('vistas').find_one({
        _id: vista_id
      })

      vista.merge!({
        'photo_thumb' => '',
        'photo_main' => ''
      })
      if vista['default_photo']
        photo = inflate_photo(vista_id, vista['default_photo'])
        vista['photo_thumb'] = photo[:thumb].url
        vista['photo_main'] = photo[:main].url
      end
      return vista
    end

    def self.visits(vista_id)
      visits = Vista::Visits.where(vista_id: vista_id).to_a
      users = visits.map{|v| v['email']}.uniq
      db_users = ::User.where(email: users).index_by(&:email)
      ret = visits.map{|v| { username: db_users[v['email']].username, date: v['date'].strftime("%Y-%m-%d")}}
      return ret
    end

    def self.inflate_one(vista, q)
      if q[:lat] && q[:lon]
        coords = vista['geometry']['coordinates']
        vlon = coords[0]
        vlat = coords[1]
        vista[:dis] = Vista::Geo.haversine(q[:lat].to_f, q[:lon].to_f, vlat, vlon).to_s # string
      end
      vista[:visits] = visits(vista['_id'])
      vista
    end

    def self.inflate(vistas, q)
      vistas.each do |vista|
        inflate_one(vista, q)
      end
      vistas
    end

    def self.find_vistas(vista_ids)
      return [] unless vista_ids
      coll('vistas').find({
        _id: {'$in' => vista_ids}
      }).to_a
    end

    def self.add_photo(vista_id, user_email, photo_id, approved = false)
      coll('vistas').update({ _id: vista_id },
        {
          "$push" => {
            photos: {
              user_email: user_email,
              photo_id: photo_id,
              approved: approved
            }
          }
        })
    end

    def self.list_photos(vista_id)
      photos = inflate_photos(vista_id, find(vista_id)['photos'] || [])
      return photos
    end
  end
end
