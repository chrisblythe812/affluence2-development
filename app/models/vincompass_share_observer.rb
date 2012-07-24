class VincompassShareObserver < ActiveRecord::Observer


  def after_create(vincompass_share)
    user = vincompass_share.promotion.promotions_users.first.user
    Activity.create(:user_id => user.id,
                    :body => user.profile.name + ' shared WineShare ',
                    :resource_type => 'VincompassShare',
                    :resource_id => vincompass_share.id)
  end


end
