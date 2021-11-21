class UserInfoSerializer < UserSerializer
  attributes :sex, :website, :full_years, :locale

  delegate :full_years, to: :view

private

  def view
    @view ||= Profiles::View.new object
  end
end
