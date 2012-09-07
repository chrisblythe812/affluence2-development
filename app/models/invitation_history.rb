class InvitationHistory < ActiveRecord::Base
  belongs_to :user


  def get_status  
    case status
      when 0
        "Expired"
      when 1
        "Pending"
      when 2
        "Accepted"
      when 3
        "Accepted - Credit Points Earned"
      when 4
        "Accepted - Credit Points Redeemed"
    end
  end
end
