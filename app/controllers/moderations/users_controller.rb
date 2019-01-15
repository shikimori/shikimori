class Moderations::UsersController < ModerationsController
  LIMIT = 64

  def index # rubocop:disable AbcSize
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    scope = Users::Query.fetch
      .search(params[:search])
      .created_on(params[:created_on])

    if can? :manage, Ban
      scope = scope
        .id(params[:id])
        .current_sign_in_ip(params[:current_sign_in_ip])
        .last_sign_in_ip(params[:last_sign_in_ip])
    end

    @collection = scope.paginate(@page, LIMIT)
  end
end
