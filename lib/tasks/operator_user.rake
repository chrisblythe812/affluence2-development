namespace :affluence2 do
  desc "This will create default operator user"
  task :create_operator_user => :environment do
    ['support@example.com','support1@example.com','support2@example.com'].each_with_index do |email, i|
      user = User.find_by_email(email)
      if user.blank?
        user = User.new(:email => email, :password => 'password', :role => 'operator', :plan => 'free')
        profile = user.build_profile(:first_name => "support#{i}", :last_name => "team#{i}",:city=> 'Hyderabad', :country => 'India')
      user.save
      end  
    end
  end

end

