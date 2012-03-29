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

  # The same, but using a string instead of class constant
  factory :profile, :class => 'profile' do
    user_id  { |a| a.association(:user) }
    city     'Chicago'
    state    'IL'
    country  'US'
    phone    '+1230032143'
    bio      'CEO of Affluence'
    title        'CEO'
    company      'Affluence'
    last_name    'Davidson'
    middle_name  ''
    first_name   'John'
    full_name    "#{first_name} #{last_name}"
  end
  factory :photo, :class => 'photo' do
    user_id  { |a| a.association(:user) }
    city     'Chicago'
    state    'IL'
    country  'US'
    phone    '+1230032143'
    bio      'CEO of Affluence'
    title        'CEO'
    company      'Affluence'
    last_name    'Davidson'
    middle_name  ''
    first_name   'John'
    full_name    "#{first_name} #{last_name}"
  end
end 