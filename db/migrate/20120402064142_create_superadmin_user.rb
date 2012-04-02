class CreateSuperadminUser < ActiveRecord::Migration
  def up
    user = User.new(:email => 'default@example.com', :password => 'password', :role => 'superadmin', :plan => 'free')
    profile = user.build_profile(:first_name => 'admin', :last_name => 'user',:country => 'India')
    user.save!
  end

  def down
    User.find_by_email('default@example.com').try(:delete)
  end
end
