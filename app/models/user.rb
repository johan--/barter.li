require 'digest/md5'
class User < ActiveRecord::Base
  include UniqueId
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_save :ensure_authentication_token
  after_create :generate_share_token
  devise :database_authenticatable, :omniauthable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  has_many :books, :dependent => :destroy
  has_many :settings, :dependent => :destroy
  has_many :email_tracks, :dependent => :destroy
  has_many :wish_lists, :dependent => :destroy
  has_many :alerts, :dependent => :destroy
  has_many :authentications, :dependent => :destroy
  has_many :user_shares, :dependent => :destroy
  has_many :user_book_visits, :dependent => :destroy
  has_many :user_feedbacks, :dependent => :destroy
  has_many :chat_filters, :dependent => :destroy
  has_many :user_reviews
  mount_uploader :profile, ImageUploader

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def change_lowercase
    self.country.downcase! if self.country
    self.state.downcase! if self.state
    self.city.downcase! if self.city
    self.street.downcase! if self.street
    self.locality.downcase! if self.locality
  end

  # send wish list mail for users
  # attributs book model object, wishlist model object
  def mail_wish_list(book, wishlist)
    if self.can_send_mail
      Notifier.wish_list_book(self, book).deliver
      save_email_track(Code[:wish_list_book])
    end
  end

  # profile image
  def absolute_profile_image(host)
    return self.ext_image if self.ext_image.present?
    image_path = ActionController::Base.helpers.asset_path(self.profile.url)
    return "http://#{host}#{image_path}"
  end  
 
  # checks whether email can be sent based on user settings 
  # for no of emails and duration
  def can_send_mail
    month_emails = self.mails_by_month(Time.now.month)
    if(month_emails.count < self.setting_email_count_month )
      return true if month_emails.count == 0
      last_email_sent = month_emails.first.created_at
      (mail_duration(last_email_sent) >= self.setting_email_duration) ? true : false
    else
      false
    end
  end

  def chat_block(user_id)
    self.chat_filters.create!(block_id: user_id)
  end


  def is_chat_blocked(user_id)
    is_blocked = self.chat_filters.where(block_id: user_id).first
    if(is_blocked.present?)
      return true
    else
      return false
    end
  end

  def setting_email_duration
    duration = self.settings.find_by(:name => "email_duration")
    duration = duration.present? ? duration.value.to_i : DefaultSetting.email_duration.to_i
  end

  def setting_email_count_month
    email_per_month = self.settings.find_by(:name => "email_per_month")
    email_per_month = email_per_month.present? ? email_per_month.value.to_i : DefaultSetting.email_per_month.to_i
  end
  
  # attributes
  # time_date :time object ex: time.now
  def mail_duration(time_date)
    duration_difference = Time.now.to_i - time_date.to_i
  end

  def profile_image
    return  self.profile.url
  end

  def attributes
    super.merge({'profile_image' => profile_image})
  end
  
  # attributes
  # month :an integer representation of month ex: 1 or 01
  def mails_by_month(month)
    month_emails = self.email_tracks.where('extract(month from created_at) = ?', month).order(created_at: :desc)
  end
  
  # attributes
  # sent_for :a code to identify why the email is sent
  def save_email_track(sent_for)
    email_track = self.email_tracks.new()
    email_track.sent_for = sent_for
    email_track.save
  end
 
  # attributes
  # obj :object to create alert for, alert_type :type of alert
  def create_alert(obj, alert_type)
    alert = self.alerts.new
    alert.thing = obj
    alert.reason_type = alert_type
    alert.save
  end
  
  def apply_omniauth(omni)
    self.authentications.create(:provider => omni['provider'], :uid => omni['uid'],
    :token => omni['credentials'].token, :token_secret => omni['credentials'].secret)
  end

  def set_preferred_location(params)
    location = Location.find_by(:latitude => params[:latitude], :longitude => params[:longitude], :name => params[:name])
    setting = self.settings.find_by(name: "location")
    setting.destroy if setting.present?
    if(location.present?)
      setting = self.settings.create(:name => "location", :value => location.id)
      return location
    else
      location = Location.create!(:latitude => params[:latitude], :longitude => params[:longitude], :name => params[:name], :country => params[:country], :city => params[:city], :state => params[:state] ,:address => params[:address])
      setting = self.settings.create(:name => "location", :value => location.id)
      return location
    end
  end

  def preferred_location
    location = self.settings.find_by(:name => "location")
    if(location.present?)
      return location = Location.find(location.value)
    else
      return location = nil
    end
  end
  
  def generate_share_token
    token = Digest::MD5.hexdigest(self.email)
    self.share_token = token
    self.save
    token
  end

  def self.user_by_token(token)
    user = User.find(share_token: token)
    return user
  end

  def self.register_shares(token)
    link_user = User.user_by_roken(token)
    link_user.user_shares.new(share_user_id: self.id)
    link_user.save
  end


  def send_password_reset
    self.reset_password_token =  SecureRandom.random_number(88888888)
    self.reset_password_sent_at = Time.zone.now
    save!
    Notifier.password_reset(self).deliver
  end

  def self.create_or_find_by_email_and_password(email, password)
    user = User.find_by(email: email)
    if(user.present?)
      return user if user.valid_password?(password)
      return false
    else
      user = User.create!(email: email, password: password)
      return user
    end
  end

  private
    def generate_authentication_token
      loop do
        token = Devise.friendly_token
        break token unless User.where(authentication_token: token).first
      end
    end

end
