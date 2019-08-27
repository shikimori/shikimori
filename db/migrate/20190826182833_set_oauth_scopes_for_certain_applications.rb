class SetOauthScopesForCertainApplications < ActiveRecord::Migration[5.2]
  DEFAULT_SCOPES = %i[user_rates comments topics]

  def change
    OauthApplication.update_all scopes: DEFAULT_SCOPES.join(' ')
    Doorkeeper::AccessGrant.update_all scopes: DEFAULT_SCOPES.join(' ')
    Doorkeeper::AccessToken.update_all scopes: DEFAULT_SCOPES.join(' ')

    OauthApplication.where(id: 15).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    Doorkeeper::AccessGrant.where(application_id: 15).update_all scopes: DEFAULT_SCOPES.join(' ')
    Doorkeeper::AccessToken.where(application_id: 15).update_all scopes: DEFAULT_SCOPES.join(' ')

    OauthApplication.where(id: 31).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    Doorkeeper::AccessGrant.where(application_id: 31).update_all scopes: DEFAULT_SCOPES.join(' ')
    Doorkeeper::AccessToken.where(application_id: 31).update_all scopes: DEFAULT_SCOPES.join(' ')
  end
end
