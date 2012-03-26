# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

images =['events-1.jpg', 'events-2.jpg', 'events-3.jpg', 'offer-1.jpg', 'offer-2.jpg', 'offer-3.jpg', 'profile-1.jpg', 'profile-2.jpg', 'profile-3.jpg', 'profile-4.jpg']
# Events seed data
  Event.all.each{|event| event.destroy}  
#<Event id: nil, title: nil, description: nil, price: nil, created_at: nil, updated_at: nil>
#  
#<Promotion id: nil, promotionable_id: nil, promotionable_type: "Event", created_at: nil, updated_at: nil>
#
#<Photo id: nil, photoable_id: nil, photoable_type: "Promotion", title: nil, description: nil, created_at: nil, updated_at: nil, image_file_name: nil, image_content_type: nil, image_file_size: nil, image_updated_at: nil>
  
events_seed =[
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
  }]
events=[]
events_seed.each do |event|
  events << Event.create(event)
end

promotions = []
events.each do |event|
    event.build_promotion
    event.save!
    promotions << event.promotion
end

photos=[
  {
    title: 'Grammy Event & Party',
    description: 'Join Affluence for an all access pass to the 2012 Grammys. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.'
  },
  {
    title: 'Weekend at the Masters',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.'
   },
  {
    title: '2012 Oscars Party',
    description: 'Let Affluence treat you to a Masters like you have never experienced before. Enjoy Saturday and Sunday event passes with all access to every tent and party.'
   },
  {
    title: '2012 New Year Party',
    description: 'Join Affluence for an all access pass to the 2012 New Year Party. Walk the red carpet, enjoy the show and party the night away at the exclusive after hours party at the W.' 
   }]


promotions.each do |promotion|
  promotion.photos.build(photos)
  promotion.photos.each {|x| x.image = File.new(Rails.root.join("app", "assets", "images", images.sample).to_s)}
  promotion.save!
end
 


# Offers seed data
  Offer.all.each{|offer| offer.destroy}


#<Offer id: nil, title: nil, description: nil, created_at: nil, updated_at: nil>

#<Promotion id: nil, promotionable_id: nil, promotionable_type: "Offer", created_at: nil, updated_at: nil>

#<Photo id: nil, photoable_id: nil, photoable_type: "Promotion", title: nil, description: nil, created_at: nil, updated_at: nil, image_file_name: nil, image_content_type: nil, image_file_size: nil, image_updated_at: nil>


offers_seed =[
  {
    title: '60% Off Flying Private',
    description: 'Fly private for as little as $3,000/hr.'
  },
  {
    title: 'Small Luxury Hotel Upgrades',
    description: 'Free room upgrade, late checkout & more.'
  },
  {
    title: '30% Off Lifelock',
    description: 'Protect your identity for less than $7 a month.'
  },
  {
    title: '5% off on ebay',
    description: 'Buy any electronic gadgets and get 5% off.'
  }]
offers =[]
offers_seed.each do |offer|
  offers << Offer.create(offer)
end

promotions = []
offers.each do |offer|
    offer.build_promotion
    offer.save!
    promotions << offer.promotion
end


photos=[
  {
    title: '60% Off Flying Private',
    description: 'Fly private for as little as $3,000/hr.'
  },
  {
    title: 'Small Luxury Hotel Upgrades',
    description: 'Free room upgrade, late checkout & more.'
  },
  {
    title: '30% Off Lifelock',
    description: 'Protect your identity for less than $7 a month.'
  },
  {
    title: '5% off on ebay',
    description: 'Buy any electronic gadgets and get 5% off.'
  }]

offers.each {|offer| offer.save!}

promotions.each do |promotion|
  promotion.photos.build(photos)
  promotion.photos.each {|x| x.image = File.new(Rails.root.join("app", "assets", "images", images.sample).to_s)}
  promotion.save!
end


#
# user seed data
User.all.each {|user| user.destroy unless user.role == 'superadmin'}

i=0
while i < 30
  i = i + 1 
  user = User.new(:email => "john+#{i.to_s}@gmail.com", :password => 'password', :password_confirmation => 'password', :plan => 'free', :role => 'member')
  profile = user.build_profile(:first_name=>'John'+i.to_s, :last_name=>'Davidson', :city=>'hyderabad', :country=>'India')
  user.save
  photo = profile.photos.build
  photo.image=File.new(Rails.root.join("app", "assets", "images", images.sample).to_s)
  profile.save
 end
 