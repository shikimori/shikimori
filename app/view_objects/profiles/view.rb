class Profiles::View < ViewObjectBase
  vattr_initialize :user

  BANNED_PROFILES = %w[7683]
  CACHE_VERSION = :v1

  def history_view
    @history_view ||= Profiles::HistoryView.new @user
  end

  def achievements_preview_view
    @achievements_preview_view ||= Profiles::AchievementsPreviewView.new @user, own_profile?
  end

  def compatibility_view
    @compatibility_view ||= Profiles::CompatibilityView.new @user
  end

  def own_profile?
    h.user_signed_in? && h.current_user.id == @user.id
  end

  def censored_profile?
    (@user.censored_profile? || @user.forever_banned?) && !own_profile?
  end

  def show_comments?
    !censored_profile? &&
      h.user_signed_in? &&
      # (h.user_signed_in? || @user.comments.any?) &&
      @user.preferences.comments_in_profile?
  end

  def ignored?
    if h.user_signed_in?
      h.current_user.ignores.any? { |v| v.target_id == @user.id }
    else
      false
    end
  end

  def avatar_url size = 160
    @user.avatar_url size, own_profile?
  end

  def about_html
    return if censored_profile?

    text = @user.about || ''
    cache_key = CacheHelperInstance.cache_keys(
      @user.cache_key,
      XXhash.xxh32(text),
      CACHE_VERSION
    )

    Rails.cache.fetch(cache_key) { BbCodes::Text.call text }
  end

  def common_info
    info = []

    info << "id: #{@user.id}" if h.user_signed_in? && h.current_user.admin?

    if h.can? :access_list, @user
      # info << h.h(@user.name)
      unless @user.sex.blank?
        info << i18n_t('male') if @user.male?
        info << i18n_t('female') if @user.female?
      end
      if @user.birth_on.present? && full_years > 12 && @user.preferences.is_show_age?
        info << "#{full_years} #{i18n_i 'years_old', full_years}"
      end
      # info << @user.location
      info << @user.website

      info.select!(&:present?)
      info << i18n_t('no_personal_data') if info.empty?
    else
      info << i18n_t('personal_data_hidden')
    end

    info << "#{i18n_t 'member_since'} " \
      "<span class='b-tooltipped dotted mobile unprocessed' data-direction='right' "\
      "title='#{localized_registration false}'>#{localized_registration true}" \
      '</span>'.html_safe

    info
  end

  def localized_registration shortened
    if @user.created_at > 2.months.ago || !shortened
      h.l @user.created_at, format: i18n_t('registration_formats.full')

    elsif @user.created_at > 2.years.ago
      h.l(
        @user.created_at, format: i18n_t('registration_formats.month_year')
      ).sub(/^\d+ /, '') # замена делается т.к. в русском варианте
      # если брать перевод даты без %d, то месяц будет в неправильном падеже

    else
      h.l @user.created_at, format: i18n_t('registration_formats.year')
    end
  end

  def full_years
    return unless @user.birth_on

    years_passed = Time.zone.today.year - @user.birth_on.year

    Time.zone.tomorrow - years_passed.years > @user.birth_on ?
      years_passed :
      years_passed - 1
  end
end
