class Moderations::UsersController < ModerationsController
  PER_PAGE = 44
  MAX_BAN_USERS_LIMIT = 600
  MASS_BAN_ERROR_ALERT =
    'Массовый бан можно выдавать только выборкам размером менее ' \
      "#{MAX_BAN_USERS_LIMIT} пользователей"
  MASS_BAN_NOTICE = 'Пользователи забанены на 10 лет. Запись о банах внесена в логи.'

  MASS_REGISTRATION_INTERVAL = 1.month
  MASS_REGISTRATION_THRESHOLD = 10

  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    og noindex: true, nofollow: true
    og page_title: i18n_t('page_title')

    if params[:mass_ban]
      authorize! :mass_ban, User

      if users_scope.size >= MAX_BAN_USERS_LIMIT
        return redirect_to current_url(mass_ban: nil), alert: MASS_BAN_ERROR_ALERT
      end

      changelog_logger.info(
        user_id: current_user.id,
        action: :mass_ban,
        ids: users_scope.pluck(:id),
        url: current_url(mass_ban: nil)
      )
      User
        .where(id: users_scope.reject(&:staff?).pluck(:id))
        .update_all(read_only_at: 10.years.from_now)
      return redirect_to current_url(mass_ban: nil), notice: MASS_BAN_NOTICE
    end

    @collection = users_scope.paginate(@page, PER_PAGE)
    @collection_size = @collection.except(:limit, :offset).size

    @mass_registration_threshold = (
      params[:mass_registration_threshold] || MASS_REGISTRATION_THRESHOLD
    ).to_i
    @mass_ips = fetch_mass_ips
  end

private

  def users_scope # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    scope = Users::Query.fetch
      .search(params[:phrase])
      .created_on(
        params[:created_on_1],
        params[:created_on_1_condition].presence || Users::Query::ConditionType[:eq]
      )
      .created_on(
        params[:created_on_2],
        params[:created_on_2_condition].presence || Users::Query::ConditionType[:eq]
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
      .where(read_only_at: nil)
      .group_by(&:current_sign_in_ip)
      .map { |ip, users| [ip, users.size, users] }
      .select { |(_ip, size, _users)| size > @mass_registration_threshold }
      .sort_by { |ip, size, _users| [-size, ip] }
      .each_with_object({}) { |(ip, size, _users), memo| memo[ip] = size }
  end

  def changelog_logger
    @logger ||= NamedLogger.changelog_mass_bans
  end
end
