class Moderations::RolesController < ModerationsController
  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')
  end

  def show
    # if params[:id] =~ /\Anot_trusted_(?<role>[\w_]+)\Z/ &&
    #     !current_user.send("#{$LAST_MATCH_INFO[:role].gsub 'changer', 'moderator'}?")
    #   raise CanCan::AccessDenied
    # end

    og noindex: true, nofollow: true
    og page_title: params[:id].titleize

    breadcrumb i18n_t('page_title'), moderations_roles_url
    @back_url = moderations_roles_url

    @collection = users_scope
  end

private

  def users_scope
    User
      .where("roles && '{#{Types::User::Roles[params[:id]]}}'")
      .where(("id != #{User::MORR_ID}" if params[:id] != 'admin'))
      .order(:nickname)
      .decorate
  rescue Dry::Types::ConstraintError
    redirect_to moderations_roles_url
  end
end
