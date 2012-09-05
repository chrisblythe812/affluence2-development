class InvitationHistory < ActiveRecord::Base
  belongs_to :user


  def get_status  
    case status
      when 0
        "Pending"
      when 1
        "Accepted"
      when 2
        "Expired"
    end
  end
end
