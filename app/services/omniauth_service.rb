class OmniauthService
  def initialize user, omniauth_data
    @omni = omniauth_data
    @user = user
  end

  def populate
    if @omni['provider']
      fill_facebook_fields if facebook?
      fill_vkontakte_fields if vkontakte?
    end
    fill_common_fields
    @user.nickname = @user.nickname[0..User::MAX_NICKNAME_LENGTH-1] if @user.nickname.length >= User::MAX_NICKNAME_LENGTH
    build_token

    @user.nickname = 'Новый пользователь' if @user.nickname.blank?
    @user.email = generate_email if @user.email.blank?
  end

private
  def fill_facebook_fields
    @user.location = @omni.extra.raw_info['location']['name'] if @user.location.blank? && @omni.extra.raw_info['location'] && @omni.extra.raw_info['location']['name'].present?

    if @user.sex.blank? && @omni.extra.raw_info['gender'].present?
      @user.sex = if @omni.extra.raw_info['gender'] == 'male'
        'male'
      elsif @omni.extra.raw_info['gender'] == 'female'
        'female'
      end
    end
  end

  def fill_vkontakte_fields
    @user.avatar = open @omni.extra.raw_info['photo_big'] if !@user.avatar.present? && @omni.extra.raw_info['photo_big'].present? && @omni.extra.raw_info['photo_big'] =~ /^https?:\/\//
    @user.avatar = open @omni.info.image if !@user.avatar.present? && @omni.info.image.present? && @omni.info.image =~ /^https?:\/\//

    if @user.sex.blank? && @omni.extra.raw_info['sex'].present?
      @user.sex = if @omni.extra.raw_info['sex'] == '2'
        'male'
      elsif @omni.extra.raw_info['sex'] == '1'
        'female'
      end
    end

    begin
      @user.birth_on = DateTime.parse(@omni.extra.raw_info['bdate']) unless @user.birth_on.present? || !@omni.extra.raw_info['bdate'].present?
    rescue
    end
  end

  def fill_common_fields
    @user.nickname = @omni.info.nickname if @user.nickname.blank? && @omni.info.nickname.present?
    @user.nickname = @omni.info.name if @user.nickname.blank? && @omni.info.name.present?
    @user.name = @omni.info.name if @user.name.blank? && @omni.info.name.present?
    @user.email = @omni.info.email if @user.email.blank? && @omni.info.email.present?
    @user.about = @omni.info.description if @user.about.blank?
    @user.website = @omni.info.urls.values.select(&:present?).first if @user.website.blank? && @omni.info.urls.kind_of?(Hash)
    @user.location = @omni.info.location.sub(/,\s*$/, '') if @user.location.blank? && @omni.info.location.present? && @omni.info.location !~ /^[ ,]$/

    # тут может какая-то хрень придти, не являющаяся датой
    begin
      @user.birth_on = DateTime.parse @omni.info.birth_date unless @user.birth_on.present? || !@omni.info.birth_date.present?
    rescue
    end
  end

  def build_token
    @user.user_tokens.build(provider: @omni.provider, uid: @omni.uid) do |token|
      token.secret = @omni.credentials.secret if @omni.credentials && @omni.credentials.secrect
      token.token = @omni.credentials.token if @omni.credentials && @omni.credentials.token
      token.nickname = @omni.info.nickname if @omni.info && @omni.info.nickname
    end
  end

  def generate_email
    values = [rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x1000000), rand(0x1000000)]
    fast_token = "%04x%04x%04x%04x%04x%06x%06x" % values

    "generated_#{fast_token}@shikimori.org"
  end

  def facebook?
    @omni.provider == 'facebook'
  end

  def vkontakte?
    @omni.provider == 'vkontakte'
  end
end
