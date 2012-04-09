# This will guess the User class
FactoryGirl.define do
  #<User id: nil, email: "", encrypted_password: "", reset_password_token: nil,
  # reset_password_sent_at: nil, remember_created_at: nil,
  # sign_in_count: 0, current_sign_in_at: nil,
  # last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil,
  # created_at: nil, updated_at: nil, status: nil, role: nil, unread_messages_counter: 0,
  # plan: nil, permalink: nil>
  factory :user do
    email 'john+1@gmail.com'
    password 'password'
    password_confirmation 'password'
    role 'member'
    plan 'free'
    permalink ''
  end

  # The same, but using a string instead of class constant
  factory :admin, :class => 'user' do
    email 'default@example.com'
    password 'password'
    password_confirmation 'password'
    role 'superadmin'
    plan 'free'
  end
end
