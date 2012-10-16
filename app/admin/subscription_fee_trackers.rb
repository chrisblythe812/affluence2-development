ActiveAdmin.register SubscriptionFeeTracker do

  menu :label => "User Subscriptions"

  actions :all, :except => [:new]

  config.sort_order = 'renewal_date_desc'

  filter :user_email, :as => "string"
  filter :user_profile_first_name, :as => "string"
  filter :user_profile_last_name, :as => "string"

  scope :pending, :default => true
  scope :failed


  menu :if => proc{ current_user.superadmin? }



  index do
    column("Name") do |subscription|
      auto_link(subscription.user)
    end
    column("Email") do |subscription|
      !subscription.user.blank? ?  subscription.user.email : "nil"
    end
    column("Amount") do |subscription|
      "$#{subscription.amount}"
    end
    column("Membership plan") do |subscription|
      !subscription.user.blank? ?  subscription.user.plan : "nil"
    end
    column("Renewal Date") { |subscription| global_date_format(subscription.renewal_date) }
    column('Actions', :sortable => false) do |subscription|
      link_to 'View', admin_subscription_fee_tracker_path(subscription.id)
      link_to 'Edit', edit_admin_subscription_fee_tracker_path(subscription.id)
    end
  end


  form  do |f|
    f.inputs "Edit Subscription Info" do
      f.input :renewal_date , :label => "Renewal Date"
      f.input :amount , :label => "Amount"
    end
    f.buttons
  end



end
