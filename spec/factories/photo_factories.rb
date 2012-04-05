FactoryGirl.define do
  factory :photo, :class => 'photo' do
    association :photoable
    title "photo title"
    description "photo description"
    image_file_name ""
    image_file_size ""
    image_content_type ""
    image_updated_at ""
  end
end