class VincompassShare < ActiveRecord::Base

  has_one :promotion, :as => :promotionable, :dependent => :destroy
  has_one :wine_share, :dependent => :destroy
  attr_accessor :wine_name, :year, :region, :grape, :producer, :link, :comment,:restaurant_name, :photo_url
  after_create :attach_wine

  private

  def attach_wine
    build_wine_share({
                         :name => wine_name,
                         :year => year,
                         :grape => grape,
                         :region => region,
                         :producer => producer,
                         :restaurant_name => restaurant_name,
                         :link => link,
                         :comment => comment,
                         :photo_url => photo_url})
  end

end
