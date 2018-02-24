class Users::GrantedApplications
  method_object :user

  def call
    OauthApplication.where(id: granted_application_ids(@user)).order(:id)
  end

private

  def granted_application_ids user
    user.access_grants.select('distinct(application_id) as application_id')
  end
end
