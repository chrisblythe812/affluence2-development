
# This will guess the User class
FactoryGirl.define do
  #<User id: nil, email: "", encrypted_password: "", reset_password_token: nil,
  # reset_password_sent_at: nil, remember_created_at: nil,
  # sign_in_count: 0, current_sign_in_at: nil,
  # last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil,
  # created_at: nil, updated_at: nil, status: nil, role: nil, unread_messages_counter: 0,
  # plan: nil, permalink: nil>
  sequence(:email) {|n| "person-#{n}@example.com" }

  factory :user do
    email {"user_#{rand(100000).to_s}@example.com" }
    password 'password'
    password_confirmation 'password'
    permalink ''

    trait :member_free do
      role 'member'
      plan 'free'
      verified false
    end

    trait :member_free_vetted do
        role 'member'
        plan 'free'
        verified true
    end

    trait :member_paid_monthly do
        role 'member'
        plan 'Monthly'
        verified false
    end

    trait :member_paid_yearly do
        role 'member'
        plan 'Yearly'
        verified false
    end

    trait :member_paid_monthly_vetted do
        role 'member'
        plan 'Monthly'
        verified true
    end

    trait :member_paid_yearly_vetted do
        role 'member'
        plan 'Yearly'
        verified true
    end

    trait :operator do
        role 'operator'
        plan 'free'
        verified false
    end

    trait :admin do
        role 'superadmin'
        plan 'free'
        verified false
    end

  end
end

