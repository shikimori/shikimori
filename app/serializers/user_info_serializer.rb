class UserInfoSerializer < UserSerializer
  attributes :name, :sex, :website, :birth_on, :full_years, :locale

  delegate :full_years, to: :age

  def name
    nil
  end

  def birth_on
    nil
  end

private

  def age
    object.age if object.preferences.show_age?
  end
end
