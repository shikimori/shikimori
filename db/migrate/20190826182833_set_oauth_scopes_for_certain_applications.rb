class SetOauthScopesForCertainApplications < ActiveRecord::Migration[5.2]
  DEFAULT_SCOPES = %i[user_rates comments topics]

  def change
    OauthApplication.update_all scopes: DEFAULT_SCOPES.join(' ')
    OauthApplication.where(id: 31).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
  end
end
