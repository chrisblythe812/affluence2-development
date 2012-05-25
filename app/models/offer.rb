class Offer < ActiveRecord::Base
  attr_accessor :offer_image
  has_one :promotion, :as => :promotionable, :dependent => :destroy

 # Select N top users. Returns 10 entries when called without arguments.
  #   User.top.all.size    # => 10
  #   User.top(2).all.size # => 2
  #
  scope :active, where(:active => true)
  scope :dinning, where(:category => 'Dinning')
  scope :travel, where(:category => 'Travel')
  scope :financial, where(:category => 'Financial')
  scope :shopping, where(:category => 'Shopping')
  scope :services, where(:category => 'Services')

  scope :latest, lambda { |*args| { :limit => (args.size > 0 ? args[0] : 3), :order => "id desc" } }


end
