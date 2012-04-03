class Offer < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy

 # Select N top users. Returns 10 entries when called without arguments.
  #   User.top.all.size    # => 10
  #   User.top(2).all.size # => 2
  #
  scope :latest, lambda { |*args| { :limit => (args.size > 0 ? args[0] : 3), :order => "id desc" } }


end
