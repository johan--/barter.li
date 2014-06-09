class UserProfileSerializer < ActiveModel::Serializer
  cached
  attributes :first_name, :last_name, :id_user, :location, :image_url, 
  :description, :referral_count
  has_many :books


  def image_url
    # return object.ext_image if object.ext_image.present?
    url = @options[:url_options]
    port = url[:port].present? ?  ":"+url[:port].to_s: ""
    object.absolute_profile_image("http://#{url[:host]}#{port}")
  end

  def location
    location = object.settings.find_by(:name => "location")
    if(location.present?)
      location = Location.find(location.value)
      return location.as_json(except: [:created_at, :updated_at])
    else
      return location = nil
    end  
  end

  def referral_count
    object.user_referrals.count
  end

  def cache_key
    [object, scope]
  end

end