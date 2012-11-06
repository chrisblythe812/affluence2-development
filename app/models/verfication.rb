class Verfication < ActiveRecord::Base
  belongs_to :user

  scope :to_be_verified, :conditions => ['status like ?', 'submited']
  scope :verified,:conditions => ['status like ?', 'verified']
  scope :rejected,:conditions => ['status like ?', 'rejected']



  def check_completed_status?
    (status == "submited" && !completed)
  end
end
