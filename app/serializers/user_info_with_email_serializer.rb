class UserInfoWithEmailSerializer < UserInfoSerializer
  attributes :email

  def email
    object.email unless object.generated_email?
  end
end
