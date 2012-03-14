class CreateSuperadminUser < ActiveRecord::Migration
  def up
    User.create! do |r|
      r.email      = 'default@example.com'
      r.password   = 'password'
      r.role = 'superadmin'
    end
  end

  def down
    User.find_by_email('default@example.com').try(:delete)
  end
end
