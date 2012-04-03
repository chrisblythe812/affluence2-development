FactoryGirl.define do
  factory :photo, :class => 'photo' do

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