class User < ActiveRecord::Base
  has_many :presentations

  has_many :participations
  has_many :events, through: :participations

  validates :full_name, presence: true

  scope :publicized, where(publicized: true)

  def description
    "Hi my name is and i like doing this and that :)"
  end

  def attend(event)
    if events.include?(event)
      :already_signed
    else
      events << event
      if save
        :signed
      else
        :error
      end
    end
  end

  def self.from_omniauth(auth)
    field = case auth.provider
      when 'facebook' then 'facebook_uid'
      when 'github' then 'github_uid'
    end
    
    where_hash = {}
    where_hash[field] = auth.uid

    if field.present?
      user = where(where_hash).first
      user ||= where(email: auth.info.email).first_or_initialize.tap do |u|
        u.send("#{field}=", auth.uid)

        if u.new_record?
          u.full_name = auth.info.name
          u.email = auth.info.email
        end

        u.save!
      end
    end
    user
  end
end
