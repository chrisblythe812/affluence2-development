# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)




#<Event id: nil, title: nil, description: nil, price: nil, created_at: nil, updated_at: nil>

  #<Promotion id: nil, promotionable_id: nil, promotionable_type: "Event", created_at: nil, updated_at: nil>

 #<Photo id: nil, photoable_id: nil, photoable_type: "Promotion", title: nil, description: nil, created_at: nil, updated_at: nil, image_file_name: nil, image_content_type: nil, image_file_size: nil, image_updated_at: nil>


events=Event.create([
  {
    title: 'Grammy Event & Party',
    description: 'Join Affluence for an all access pass to the 2012 Grammys. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.',
    price: '1800'
  },
  {
    title: 'Weekend at the Masters',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.',
    price: '2200'
  },
  {
    title: '2012 Oscars Party',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.',
    price: '1100'
  },
  {
    title: '2012 New Year Party',
    description: 'Join Affluence for an all access pass to the 2012 New Year Party. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.',
    price: '180000'
  }])

promotions = []
events.each do |event|
  promotions << event.build_promotion
end

photos=[
  {
    title: 'Grammy Event & Party',
    description: 'Join Affluence for an all access pass to the 2012 Grammys. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.',
    image: File.new(Rails.root.join("app", "assets", "images", 'events-3.jpg').to_s)
  },
  {
    title: 'Weekend at the Masters',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.',
    image: File.new(Rails.root.join("app", "assets", "images", 'events-1.jpg').to_s)
  },
  {
    title: '2012 Oscars Party',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.',
    image: File.new(Rails.root.join("app", "assets", "images", 'events-2.jpg').to_s)
  },
  {
    title: '2012 New Year Party',
    description: 'Join Affluence for an all access pass to the 2012 New Year Party. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.',
    image: File.new(Rails.root.join("app", "assets", "images", 'events-4.jpg').to_s)
  }]  
  
promotions.each do |promotion|
   promotion.photos.build(photos)
  end

events.each {|event| event.save!} 

