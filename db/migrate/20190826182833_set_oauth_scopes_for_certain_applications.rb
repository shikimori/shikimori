class SetOauthScopesForCertainApplications < ActiveRecord::Migration[5.2]
  DEFAULT_SCOPES = %i[user_rates comments topics]

  def change
    # OauthApplication.update_all scopes: DEFAULT_SCOPES.join(' ')
    # Doorkeeper::AccessGrant.update_all scopes: DEFAULT_SCOPES.join(' ')
    # Doorkeeper::AccessToken.update_all scopes: DEFAULT_SCOPES.join(' ')
    #
    # OauthApplication.where(id: 15).update_all(
    #   allowed_scopes: I18n.t('doorkeeper.scopes').keys.map(&:to_s),
    #   scopes: I18n.t('doorkeeper.scopes').keys.map(&:to_s)
    # )
    # Doorkeeper::AccessGrant.where(application_id: 15).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    # Doorkeeper::AccessToken.where(application_id: 15).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    #
    # OauthApplication.where(id: 31).update_all(
    #   scopes: (DEFAULT_SCOPES + [:friends]).join(' '),
    #   allowed_scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    # )
    # Doorkeeper::AccessGrant.where(application_id: 31).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    # Doorkeeper::AccessToken.where(application_id: 31).update_all scopes: (DEFAULT_SCOPES + [:friends]).join(' ')
    #
    # OauthApplication.where(id: 200).update_all(
    #   scopes: (DEFAULT_SCOPES + [:messages]).join(' '),
    #   allowed_scopes: (DEFAULT_SCOPES + [:messages]).join(' ')
    # )
    # Doorkeeper::AccessGrant.where(application_id: 200).update_all scopes: (DEFAULT_SCOPES + [:messages]).join(' ')
    # Doorkeeper::AccessToken.where(application_id: 200).update_all scopes: (DEFAULT_SCOPES + [:messages]).join(' ')
  end
end
