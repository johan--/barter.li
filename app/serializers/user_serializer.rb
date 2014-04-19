class UserSerializer < ActiveModel::Serializer
  #cached
  attributes :id, :email, :description, :first_name, :last_name, :location, 
  :auth_token, :sign_in_count, :id_user, :image_url
  has_many :books
 
  def location
    location = object.settings.find_by(:name => "location")
    if(location.present?)
      location = Location.find(location.value)
      return location.as_json(except: [:created_at, :updated_at])
    else
      return location = nil
    end  
  end

  def auth_token
    object.authentication_token
  end

  def image_url
    return object.ext_image if object.ext_image.present?
    url = @options[:url_options]
    #return  ActionController::Base.helpers.asset_url(object.image.url)if object.image_url.present?
    port = url[:port].present? ?  ":"+url[:port].to_s: ""
    image_path = ActionController::Base.helpers.asset_path(object.profile.url)
    "#{url[:protocol]}#{url[:host]}#{port}#{image_path}"
  end
    
  def cache_key
    [object, scope]
  end

end


# t.string   "email",                  
#     t.string   "encrypted_password",     
#     t.string   "first_name"
#     t.string   "last_name"
#     t.string   "middle_name"
#     t.string   "gender"
#     t.string   "age"
#     t.string   "mobile"
#     t.string   "country"
#     t.string   "image"
#     t.string   "state"
#     t.string   "city"
#     t.string   "street"
#     t.string   "address"
#     t.string   "profile"
#     t.string   "pincode"
#     t.string   "latitude"
#     t.string   "longitude"
#     t.string   "accuracy"
#     t.string   "altitude"
#     t.boolean  "status",                 
#     t.boolean  "is_admin",               
#     t.string   "reset_password_token"
#     t.datetime "reset_password_sent_at"
#     t.datetime "remember_created_at"
#     t.integer  "sign_in_count",      
#     t.datetime "current_sign_in_at"
#     t.datetime "last_sign_in_at"
#     t.string   "current_sign_in_ip"
#     t.string   "last_sign_in_ip"
#     t.datetime "created_at"
#     t.datetime "updated_at"
#     t.string   "confirmation_token"
#     t.datetime "confirmed_at"
#     t.datetime "confirmation_sent_at"
#     t.string   "unconfirmed_email"
#     t.string   "locality"
#     t.string   "authentication_token"
#     t.text     "description"
#     t.string   "share_token"