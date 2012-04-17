FactoryGirl.define do
 # The same, but using a string instead of class constant
  factory :profile, :class => 'profile' do
    user
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
#    full_name    "#{first_name} #{last_name}"
  end
  
end