class Photo < ActiveRecord::Base
  belongs_to :photoable
  attr_accessor :parent_type

  has_attached_file :image,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "/:id/:style/:basename.:extension",
    :styles => Proc.new { |clip| clip.instance.styles }  
#  has_attached_file :avatar, :styles => lambda { |attachment| { :thumb => (attachment.instance.boss? ? "300x300>" : "100x100>") }  }

  def styles

    case   parent_type
    when 'Profile'
      { :medium => ['260x260#', :png], :thumb => ['60x60#', :png] }
    when 'Event'
      { :medium => ['360x268#', :png]}
    when 'Offer' 
      { :medium => ['210x100#', :png]}
    when 'PhotoStream'
      { :medium => ['260x180#', :png]}
    else
      { :medium => ['360x268#', :png]}
    end
  end





end
