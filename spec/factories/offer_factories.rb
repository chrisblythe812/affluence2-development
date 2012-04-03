FactoryGirl.define do
  factory :offer do
    association :photoable, factory: :photo
    title     'Small Luxury Hotel Upgrades'
    description    'Free room upgrade, late checkout & more.'
  end
end