FactoryGirl.define do
  factory :connection, :class => 'Comments' do
    user_id
    friend_id
  end
end