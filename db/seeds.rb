# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin_pw = ENV['DEFAULT_ADMIN_PW']
Admin.create(email: 'mike@mikec.me', password: admin_pw)

# Upsert vistas and update areas
load Rails.root.join('db/seeds/vistas.rb')
Vistas.each do |vista|
  Vista::Area.add_vista(vista[:name], vista[:lat], vista[:lon])
end
Vista::Area.recalculate_area_vistas
