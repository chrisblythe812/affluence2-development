namespace :affluence2 do
  desc "This will create default operator user"
  task :create_operator_user => :environment do

    user = User.find_by_email('support@example.com')
    if user.blank?
    user = User.new(:email => 'support@example.com', :password => 'password', :role => 'operator', :plan => 'free')
    profile = user.build_profile(:first_name => 'support', :last_name => 'team',:city=> 'Hyderabad', :country => 'India')
    user.save
    end
  end



end





