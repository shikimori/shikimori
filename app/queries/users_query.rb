class UsersQuery
  include CompleteQuery
  AutocompleteLimit = 10

  def initialize params
    @params = params

    @search = SearchHelper.unescape params[:search]
    @klass = User
  end

  def bans_count
    query = User.find(@params[:user_id])
      .bans
      .where("created_at > ?", DateTime.now - Ban::ACTIVE_DURATION)

    warnings = query.where(duration: 0).count
    bans = query.where("duration > 0").count

    (warnings > 0 ? 1 : 0) + bans
  end

private
  # ключи, по которым будет вестись поиск
  def search_fields term
    [:nickname]
  end
end
