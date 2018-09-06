class Moderations::RolesController < ModerationsController
  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    if params[:role].present?
      breadcrumb i18n_t('page_title'), moderations_roles_url
      @back_url = moderations_roles_url
      og page_title: params[:role].titleize

      @collection = users_scope
    else
      og page_title: i18n_t('page_title')
    end
  end

private

  def users_scope
    User
      .where("roles && '{#{Types::User::Roles[params[:role]]}}'")
      .where(("id != #{User::MORR_ID}" if params[:role] != 'admin'))
      .order(:nickname)
      .decorate
  rescue Dry::Types::ConstraintError
    redirect_to moderations_roles_url
  end
end
