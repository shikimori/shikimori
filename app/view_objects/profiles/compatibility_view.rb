class Profiles::CompatibilityView < ViewObjectBase
  pattr_initialize :user
  instance_cache :all_compatibility

  def value klass
    all_compatibility[klass.downcase.to_sym] if all_compatibility
  end

  def text klass
    number = value klass

    if number < 5
      i18n_t 'text.zero'
    elsif number < 25
      i18n_t 'text.low'
    elsif number < 40
      i18n_t 'text.moderate'
    elsif number < 60
      i18n_t 'text.high'
    else
      i18n_t 'text.full'
    end
  end

  def css_class klass
    number = value klass

    if number < 5
      'zero'
    elsif number < 25
      'weak'
    elsif number < 40
      'moderate'
    elsif number < 60
      'high'
    else
      'full'
    end
  end

private

  def all_compatibility
    CompatibilityService.fetch @user, h.current_user if h.user_signed_in?
  end
end
