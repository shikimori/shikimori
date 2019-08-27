class FillAllowedScopesForOauthApplications < ActiveRecord::Migration[5.2]
  def change
    OauthApplication.update_all allowed_scopes: %w[user_rates comments topics]
    OauthApplication.where(id: 15).update_all allowed_scopes: I18n.t('doorkeeper.scopes').keys
    OauthApplication.where(id: 31).update_all allowed_scopes: %w[user_rates comments topics friends]
  end
end
