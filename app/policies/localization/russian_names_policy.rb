class Localization::RussianNamesPolicy
  method_object :user

  def call
    !!(
      (!@user && I18n.russian?) || @user&.preferences&.russian_names?
    )
  end
end
