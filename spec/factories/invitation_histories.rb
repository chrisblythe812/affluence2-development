# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :invitation_history do
    status "MyString"
    user_id 1
    invitee_id 1
  end
end
