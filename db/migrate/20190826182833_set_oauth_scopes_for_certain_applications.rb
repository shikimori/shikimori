class SetOauthScopesForCertainApplications < ActiveRecord::Migration[5.2]
  def change
    OauthApplication.where(id: 31).update_all scopes: 'friends'
  end
end
