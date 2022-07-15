class UserInfoSerializer < UserSerializer
  attributes :name, :sex, :website, :birth_on, :full_years, :locale

  def name
    nil
  end

  def birth_on
    nil
  end

  def full_years
    object.age if object.preferences.show_age?
  end
end
