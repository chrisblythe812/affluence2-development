class CreateSuperadminUser < ActiveRecord::Migration
  def up
    user = User.find_by_email('default@example.com')
    if user.blank?
    user = User.new(:email => 'default@example.com', :password => 'password', :role => 'superadmin', :plan => 'free')
    profile = user.build_profile(:first_name => 'admin', :last_name => 'user',:city=> 'Hyderabad', :country => 'India')
    user.save
    end

  end

  def down
    User.find_by_email('default@example.com').try(:delete)
  end
end
