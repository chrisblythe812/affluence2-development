FactoryGirl.define do
  factory :event do
    title 'event title 1'
    description 'event description 1'
    price 100
    inprogress 2
    permalink 'event-1'
    start_date ''
    sale_ends_at '2012/11/4'
    tickets 30
  end

  factory :schedule do
    event
    date '2012/11/4'
    time '12:00pm'
    title 'schedule 1'
  end

  factory :include do
    event
    title 'include 1'
  end

end