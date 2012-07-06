class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :photos, :as => :photoable, :dependent => :destroy
  has_one :privacy_setting, :dependent => :destroy
  has_one :notification_setting, :dependent => :destroy
  #  has_one :photo_stream, :dependent => :destroy

  attr_accessible :invitation_source, :photos_attributes, :first_name, :last_name, :city, :country, :state, :company, :bio,
                  :middle_name, :phone, :title, :association_list, :interest_list, :expertise_list, :full_name
  acts_as_taggable_on :interests, :expertises, :associations
  accepts_nested_attributes_for :photos


  scope :member_search, lambda { |query|
    find_by_sql ["select profiles.* from profiles
      inner join users
      on (profiles.user_id=users.id)
      where (user_id is not null)
      and (users.status = 'active')
      and (
            (to_tsvector('english', COALESCE(first_name,'') || ' ' ||
                                    COALESCE(last_name,'') || ' ' ||
                                    COALESCE(title,'') || ' ' ||
                                    COALESCE(city,'') || ' ' ||
                                    COALESCE(state,'') || ' ' ||
                                    COALESCE(country,'') || ' ' ||
                                    COALESCE(company,'' ) || ' ' ||
                                    COALESCE(bio,'' )
                        )
              @@ plainto_tsquery('english', ?)
            )
          )
      order by profiles.updated_at
      desc limit 50", query]
  }


  #accepts_nested_attributes_for :user
  #attr_accessible :user_attributes

  accepts_nested_attributes_for :privacy_setting
  attr_accessible :privacy_setting_attributes


  before_create :create_associated_records

#TODO friends_profiles
#  scope :friends_profiles, lambda { |user_id|
#    joins(:user => :friendships).
#    where("friendships.friend_id = ?", user_id)
#  }

  validates_presence_of :first_name, :last_name, :city, :country


  before_save :update_full_name

  def name
    #middle = middle_name.present? ? " #{middle_name} " : " "
    "#{first_name} #{middle_name} #{last_name}"
  end

  def update_full_name
    self.full_name = name if (first_name_changed? || middle_name_changed? || last_name_changed?)
  end


  def self.get_by_matching_name(matched_name, recursive_count = 0)

    # Add the profile related direct search items
    query_text = ""
    query_params = []
    if (matched_name != nil && matched_name.chop.size > 0)
      query_text << "select profiles.* from profiles
      INNER JOIN users ON users.id = profiles.user_id
      where (user_id is not null)
      and (users.status = 'active')
      and (
            (to_tsvector('english', COALESCE(first_name,'') || ' ' ||
                                    COALESCE(last_name,'') || ' ' ||
                                    COALESCE(title,'') || ' ' ||
                                    COALESCE(city,'') || ' ' ||
                                    COALESCE(state,'') || ' ' ||
                                    COALESCE(country,'') || ' ' ||
                                    COALESCE(company,'' ) || ' ' ||
                                    COALESCE(bio,'' )
                        )
              @@ plainto_tsquery('english', ?)
            )
          )"
      query_params = [matched_name, matched_name]
    end

    recursive_count == 0 ? query_text << "  INTERSECT  " : query_text << "  UNION  "
    query_text << "select profiles.* from profiles
           INNER JOIN users ON users.id = profiles.user_id 
           where (user_id is not null)
           and (users.status = 'active') 
           and profiles.id in ( select distinct taggable_id
                       from taggings
                       where taggable_type='Profile'
                       and (context = 'interests' or context = 'expertises')
                       and tag_id
                       in (select id from tags
                           where to_tsvector('english',name)
                           @@ plainto_tsquery('english',?)
                          )
                     )"


    query_text << " order by  updated_at desc limit 50";
    query_for_find_by_sql = [query_text, query_params].flatten

    logger.info query_for_find_by_sql

    matched_profiles = Profile.find_by_sql query_for_find_by_sql

    if (recursive_count < 1 && (matched_profiles == nil || matched_profiles.size == 0))
      logger.info 'Did not match, recursively trying for all other keys'
      # There were no matching results from profile, so we search for the same query in all
      matched_profiles = get_by_matching_name(matched_name, recursive_count+1)
    end

    matched_profiles
  end

  private

  def create_associated_records
    self.build_notification_setting
    self.build_privacy_setting
  end
end
