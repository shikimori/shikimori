class Moderations::UsersController < ModerationsController
  PER_PAGE = 44
  MAX_BAN_USERS_LIMIT = 200
  MASS_BAN_ERROR_ALERT =
    "Массовый бан можно выдавать только выборкам размером < #{MAX_BAN_USERS_LIMIT} пользователей"
  MASS_BAN_NOTICE = 'Пользователи забанены на 10 лет. Запись о банах внесена в логи.'

  MASS_REGISTRATION_INTERVAL = 1.month
  MASS_REGISTRATION_THRESHOLD = 5

  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    if params[:mass_ban]
      authorize! :mass_ban, User

      if users_scope.size >= MAX_BAN_USERS_LIMIT
        return redirect_to current_url(mass_ban: nil),
          alert: MASS_BAN_ERROR_ALERT
      end
      users_scope.update_all read_only_at: 10.years.from_now
      NamedLogger.mass_ban.info(
        "User=#{current_user.id} IDS=#{users_scope.pluck(:id).join(',')}"
      )
      return redirect_to current_url(mass_ban: nil), notice: MASS_BAN_NOTICE
    end

    @collection = users_scope.paginate(@page, PER_PAGE)
    @mass_ips = fetch_mass_ips
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

  def fetch_mass_ips
    Users::Query
      .fetch
      .created_on(MASS_REGISTRATION_INTERVAL.ago.to_date.to_s, Users::Query::ConditionType[:gte])
      .group_by(&:current_sign_in_ip)
      .sort_by { |_ip, users| users.size }
      .map { |ip, users| [ip, users.size, users] }
      .reverse.select { |(_ip, size, _users)| size > MASS_REGISTRATION_THRESHOLD }
      .map(&:first)
  end
end
