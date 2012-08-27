ActiveAdmin.register Verfication do

  menu :label => "User Verifications"

  actions :all, :except => [:new,:show, :edit]

  config.sort_order = 'user_id_desc'



  scope :to_be_verified, :default => true
  scope :verified
  scope :rejected

  config.clear_sidebar_sections!


  index do
    column("Name") do |verification|
      auto_link(verification.user)
    end
    column("Email") do |verification|
      verification.user.email
    end
    column("Status", :status, :sortable => false)
    column("Membership plan") do |verification|
      verification.user.plan
    end
    column("Date") { |verification| global_date_format(verification.created_at) }
    column('Actions', :sortable => false) do |verification|
      link_to 'Verify', user_verification_admin_verfication_path(verification.id)
    end
  end


  member_action :user_verification, :method => :get do
    @verfication = Verfication.find(params[:id])
  end


  member_action :mark_as_verified, :method => :post do
    @verfication = Verfication.find(params[:id])
    @verfication.update_attribute(:status,'verified')
    user = @verfication.user
    user.verified = true
    user.save
    Notifier.verification_accepted(user.email, params[:body]).deliver
    flash[:notice] = "Member was successfully marked as verified"
    redirect_to :action => :index
  end

  member_action :mark_as_rejected, :method => :post do
    @verfication = Verfication.find(params[:id])
    @verfication.update_attribute(:status,'rejected')
    user = @verfication.user
    user.verified = false
    user.save
    Notifier.verification_rejected(user.email, params[:body]).deliver
    flash[:notice] = "Member was rejected"
    redirect_to :action => :index
  end


end
