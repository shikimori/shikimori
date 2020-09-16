class Users::PopulateOmniauth
  include Translation

  method_object :user, :omniauth

  def call
    if @omniauth['provider']
      fill_facebook_fields if facebook?
      fill_vkontakte_fields if vkontakte?
    end
    fill_common_fields
    @user.nickname = @user.nickname[0..User::MAX_NICKNAME_LENGTH-1] if @user.nickname.length >= User::MAX_NICKNAME_LENGTH
    build_token

    @user.nickname = i18n_t 'new_user' if @user.nickname.blank?
    @user.email = generate_email if @user.email.blank?
    @user
  end

private

  def fill_facebook_fields
    @user.location = @omniauth.extra.raw_info['location']['name'] if @user.location.blank? && @omniauth.extra.raw_info['location'] && @omniauth.extra.raw_info['location']['name'].present?

    if @user.sex.blank? && @omniauth.extra.raw_info['gender'].present?
      @user.sex = if @omniauth.extra.raw_info['gender'] == 'male'
        'male'
      elsif @omniauth.extra.raw_info['gender'] == 'female'
        'female'
      end
    end
  end

  def fill_vkontakte_fields
    if !@user.avatar.present? && @omniauth.extra.raw_info['photo_big'].present? &&
        @omniauth.extra.raw_info['photo_big'] =~ /^https?:\/\//
      get_avatar @omniauth.extra.raw_info['photo_big']
    end
    if !@user.avatar.present? && @omniauth.info.image.present? &&
        @omniauth.info.image =~ /^https?:\/\//
      get_avatar @omniauth.info.image 
    end

    if @user.sex.blank? && @omniauth.extra.raw_info['sex'].present?
      @user.sex =
        if @omniauth.extra.raw_info['sex'] == '2'
          'male'
        elsif @omniauth.extra.raw_info['sex'] == '1'
          'female'
        end
    end

    begin
      @user.birth_on = DateTime.parse(@omniauth.extra.raw_info['bdate']) unless @user.birth_on.present? || !@omniauth.extra.raw_info['bdate'].present?
    rescue
    end
  end

  def fill_common_fields
    @user.nickname = @omniauth.info.nickname if @user.nickname.blank? && @omniauth.info.nickname.present?
    @user.nickname = @omniauth.info.name if @user.nickname.blank? && @omniauth.info.name.present?
    @user.name = @omniauth.info.name if @user.name.blank? && @omniauth.info.name.present?
    @user.email = @omniauth.info.email if @user.email.blank? && @omniauth.info.email.present?
    @user.about = @omniauth.info.description || '' if @user.about.blank?
    @user.website = @omniauth.info.urls.values.select(&:present?).first if @user.website.blank? && @omniauth.info.urls.kind_of?(Hash)
    @user.location = @omniauth.info.location.sub(/,\s*$/, '') if @user.location.blank? && @omniauth.info.location.present? && @omniauth.info.location !~ /^[ ,]$/

    # тут может какая-то хрень придти, не являющаяся датой
    begin
      @user.birth_on = DateTime.parse @omniauth.info.birth_date unless @user.birth_on.present? || !@omniauth.info.birth_date.present?
    rescue
    end
  end

  def get_avatar url
    NamedLogger.download_avatar.info "#{url} start"
    @user.avatar = OpenURI.open_uri(url)
    NamedLogger.download_avatar.info "#{url} end"

  rescue *Network::FaradayGet::NET_ERRORS
    @user.avatar = nil
  end

  def build_token
    @user.user_tokens.build(provider: @omniauth.provider, uid: @omniauth.uid) do |token|
      token.secret = @omniauth.credentials.secret if @omniauth.credentials && @omniauth.credentials.secrect
      token.token = @omniauth.credentials.token if @omniauth.credentials && @omniauth.credentials.token
      token.nickname = @omniauth.info.nickname if @omniauth.info && @omniauth.info.nickname
    end
  end

  def generate_email
    values = [rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x0010000), rand(0x1000000), rand(0x1000000)]
    fast_token = "%04x%04x%04x%04x%04x%06x%06x" % values

    "generated_#{fast_token}@#{Shikimori::DOMAIN}"
  end

  def facebook?
    @omniauth.provider == 'facebook'
  end

  def vkontakte?
    @omniauth.provider == 'vkontakte'
  end
end
