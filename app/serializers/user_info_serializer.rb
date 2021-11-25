class UserInfoSerializer < UserSerializer
  attributes :name, :sex, :website, :birth_on, :full_years, :locale

  delegate :full_years, to: :view

  def name
    nil
  end

  def birth_on
    nil
  end

private

  def view
    @view ||= Profiles::View.new object
  end
end
