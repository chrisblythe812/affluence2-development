# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
#
images =['events-1.jpg', 'events-2.jpg', 'events-3.jpg', 'offer-1.jpg', 'offer-2.jpg', 'offer-3.jpg', 'profile-1.jpg', 'profile-2.jpg', 'profile-3.jpg', 'profile-4.jpg']

# Events seed data
Event.all.each{|event| event.destroy}

#<Event id: nil, title: nil, description: nil, price: nil, created_at: nil, updated_at: nil>
#<Promotion id: nil, promotionable_id: nil, promotionable_type: "Event", created_at: nil, updated_at: nil>
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



# user seed data
User.all.each {|user| user.destroy unless user.role == 'superadmin'}

i=0
while i < 30
  i = i + 1
  user = User.new(:email => "john+#{i.to_s}@gmail.com", :password => 'password',
    :password_confirmation => 'password', :plan => 'free', :role => 'member')
  profile = user.build_profile(:first_name=>'John'+i.to_s, :last_name=>'Davidson',
    :city=>'hyderabad', :country=>'India')
  user.save!
  photo = profile.photos.build
  photo.image=File.new(Rails.root.join("app", "assets", "images", images.sample).to_s)
  profile.save!
end

 
# conversation seed data
Conversation.all.each{|offer| offer.destroy}
Connection.all.each{|offer| offer.destroy}

subjects = ["The new baby has my old room.",
  "We decorated the room with wallpaper.",
  "A toy hangs over the crib.",
  "The baby plays most of the day.",
  "My mother sings to him at night.",
  "My friend sewed clothes for the baby.",
  "i stitched his name on the bib.",
  "Jeremy wears the bib during meals.",
  "My friend made him a  stuffed bear.",
  "I took a picture of the baby with the bear.",
  "The bear looks bigger than the baby.",
  "My father sent a copy of the picture to Aunt Carla.",
  "I took another copy to school.",
  "The teacher put the picture on the bulletin board.",
  "some students wrote stories about Jeremy.",
  "I read the stories to my parents and sister.",
  "We laughed over a story about Jeremy on Mars.",
  "My mother put the stories in a scrapbook.",
  "I pasted the picture to the inside cover.",
  "The scrapbook is for the future."
]
bodies = ["The new arrivals would start collecting samples which would be taken
back to the laboratory for analysis.",
  "This is a simple routine; the real problem lies in trying to justify its
claim to produce a random sample.",
  "Sample size was calculated according to a two-stage optimal simon's design.",
  "At the first appointment, you will usually be asked to bring a urine sample
which will be tested for the presence of protein.",
  "Questionnaires were distributed to a stratified random sample of 103 women
taken from the social services register, 38 of which were returned.
In the early summer, we invited a representative sample of firms to confirm
whether their preparations were on track.",
  "Sample chapters of this book on the oxfam site.
A blood sample is drawn by needle from a vein in the arm.
A lab-based pima service is also available to analyze samples provided to us by customers.",
  "Mp3 samples are currently being produced for our newest stock, and are also
gradually being introduced for our back catalog.",
  "
There would be no way to run a dental check or to get a dna sample.
Generally, only one needle puncture will be required to obtain all blood samples at a given time.
Rectal fecal samples were used together with the modified mcmaster technique to
calculate the egg count.",
  "The various samples were analyzed by infrared spectroscopy to assess the
usefulness of these sample preparation techniques in the field of paintings research.",
  "Small tissue samples are also be obtained using this method allowing a range
 of inflammatory and injury markers to be examined in the tissue.",
  "Image analysis, modeling skills, and experience with biological samples will
be an advantage.",
  "Your doctor may ask you to provide a stool sample which will be sent to a laboratory
 and tested.",
  "Small soil samples are taken on a grid basis, either with an auger or following
 the topsoil strip."
]

#<Conversation id: nil, created_at: nil, updated_at: nil>
#<Message id: nil, body: nil, subject: nil, sender_id: nil, recipient_id: nil, created_at: nil, updated_at: nil, conversation_id: nil>
#<ConversationMetadatum id: nil, conversation_id: nil, user_id: nil, archived: nil, read: nil, created_at: nil, updated_at: nil>

user = User.where(:email => "john+1@gmail.com").first
conversations = []
users = []
User.members.each do |user|
  user.touch
  users << user.id
end
users.delete_at(0)
sent_messages = []
20.times{
  conversations << Conversation.new
  sent_messages << {
    body: bodies.sample,
    subject: subjects.sample,
    sender_id: user.id,
    recipient_id: users.sample
  }
}

conversations.each do |conversation|
  temp = sent_messages.sample
  conversation.messages.build(temp)
  conversation.conversation_metadata.build(:user_id => temp[:recipient_id])
  conversation.save
end

conversations.each do |conversation|
  message = conversation.messages.first
  conversation.messages.build({
      sender_id: message[:recipient_id],
      recipient_id: message[:sender_id],
      subject: subjects.sample,
      body: bodies.sample
    })
  conversation.conversation_metadata.build(:user_id => message[:sender_id])
  if conversation.save!
    Connection.create(:user_id => message[:sender_id], :friend_id => message[:recipient_id])
  end

end

User.members.each do |user|
  user.profile.city = 'hyderabad'
  user.save
end

 














