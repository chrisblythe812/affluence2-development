class SubscriptionFeeTracker < ActiveRecord::Base

  belongs_to :user

  scope :status_with_date,lambda {|status, date| {:conditions => ["status like ? AND renewal_date <= ? ",status,date]}}
end
