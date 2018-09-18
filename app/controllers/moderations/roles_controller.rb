class Moderations::RolesController < ModerationsController
  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')
  end

  def show # rubocop:disable AbcSize
    # if params[:id] =~ /\Anot_trusted_(?<role>[\w_]+)\Z/ &&
    #     !current_user.send("#{$LAST_MATCH_INFO[:role].gsub 'changer', 'moderator'}?")
    #   raise CanCan::AccessDenied
    # end

    og noindex: true, nofollow: true
    og page_title: params[:id].titleize

    breadcrumb i18n_t('page_title'), moderations_roles_url
    @back_url = moderations_roles_url

    @collection = users_scope

    if params[:search]
      @searched_collection = Users::Query.fetch
        .search(params[:search])
        .paginate([params[:page].to_i, 1].max, 45)
        .transform(&:decorate)
    end
  end

private

  def users_scope
    User
      .where("roles && '{#{Types::User::Roles[params[:id]]}}'")
      .order(:nickname)
      .decorate
  rescue Dry::Types::ConstraintError
    redirect_to moderations_roles_url
  end
end
