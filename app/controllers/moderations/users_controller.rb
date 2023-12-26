class Moderations::UsersController < ModerationsController
  PER_PAGE = 44
  MAX_BAN_USERS_LIMIT = 200
  MASS_BAN_ERROR_ALERT =
    "Массовый бан можно выдавать только выборкам размером < #{MAX_BAN_USERS_LIMIT} пользователей"

  def index
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    if params[:mass_ban]
      if users_scope.size > MAX_BAN_USERS_LIMIT
        return redirect_to current_url(mass_ban: nil),
          alert: MASS_BAN_ERROR_ALERT
      end
      users_scope.update_all read_only_at: 10.years.from_now
      return redirect_to current_url(mass_ban: nil)
    end

    @collection = users_scope.paginate(@page, PER_PAGE)
  end

private

  def users_scope # rubocop:disable Metrics/AbcSize
    scope = Users::Query.fetch
      .search(params[:phrase])
      .created_on(
        params[:created_on],
        params[:created_on_condition].presence || Users::Query::ConditionType[:eq]
      )
      .email(params[:email])

    if can? :manage, Ban
      scope = scope
        .id(params[:id])
        .current_sign_in_ip(params[:current_sign_in_ip])
        .last_sign_in_ip(params[:last_sign_in_ip])
    end

    scope
  end
end
