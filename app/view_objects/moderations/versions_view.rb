class Moderations::VersionsView < ViewObjectBase # rubocop:disable ClassLength
  instance_cache :moderators, :pending, :processed

  PER_PAGE = 25
  IGNORED_FIELDS = Abilities::VersionFieldsModeratorBase
    .descendants
    .flat_map { |v| v::IGNORED_FIELDS }
    .uniq

  FILTERABLE_TYPES = [Anime, Manga, Character, Person].map(&:name)
  ALL_TYPES = :all

  MERGED_FIELDS = {
    'Video' => %w[videos],
    'Poster' => %w[image]
  }
  HIDDEN_FIELDS = MERGED_FIELDS.values.flatten

  Type = Moderation::VersionsItemTypeQuery::Type

  RULES_CLUB_PAGE_IDS = {
    Type[:all_content] => 4212,
    Type[:texts] => 4214,
    Type[:names] => 4213,
    Type[:fansub] => 4215,
    Type[:videos] => 4216,
    Type[:images] => 4217,
    Type[:links] => 4218,
    Type[:content] => 4219
  }

  def processed_scope
    Moderation::ProcessedVersionsQuery
      .fetch(type_param, h.params[:created_on])
  end

  def pending_scope
    Moderation::VersionsItemTypeQuery.fetch(type_param)
  end

  def moderators_scope nickname
    return User.none if nickname.blank?

    scope = processed_scope
      .where.not(state: %i[auto_accepted deleted])
      .distinct
      .select(:moderator_id)
      .except(:order)

    User
      .where(id: scope)
      .where('nickname ilike ?', "#{nickname}%")
  end

  def authors_scope nickname
    return User.none if nickname.blank?

    User
      .where(
        id: processed_scope
          .scope
          .or(pending_scope.scope)
          .distinct
          .select(:user_id)
          .except(:order)
      )
      .where('nickname ilike ?', "#{nickname}%")
  end

  def processed
    scope = processed_scope
    scope = apply_filters scope

    scope
      .paginate(page, PER_PAGE)
      .lazy_map(&:decorate)
  end

  def pending
    scope = pending_scope
    scope = apply_filters scope

    scope
      .includes(:user, :moderator)
      .where(state: :pending)
      .order(created_at: sort_order)
      .paginate(page, PER_PAGE)
      .lazy_map(&:decorate)
  end

  def moderators # rubocop:disable Metrics/AbcSize
    type_suffix = h.params[:type] + '_' if h.params[:type] && h.params[:type] != 'content'
    current_role = Types::User::Roles[:"version_#{type_suffix}moderator"]

    query_roles =
      if h.params[:type].blank?
        Types::User::VERSION_ROLES
      else
        [current_role]
      end

    User
      .where("roles && '{#{query_roles.join(',')}}'")
      .where.not(id: User::MORR_ID)
      .sort_by { |v| v.nickname.downcase }
  end

  def type_param
    h.params[:type]&.to_sym || :all_content
  end

  def filtered_user
    return if h.params[:user_id].blank? || cannot_filter?

    @filtered_user ||= User.find_by id: h.params[:user_id]
  end

  def filtered_moderator
    return if h.params[:moderator_id].blank? || cannot_filter?

    @filtered_moderator ||= User.find_by id: h.params[:moderator_id]
  end

  def filtered_item_type
    return if h.params[:item_type].blank? || cannot_filter?

    h.params[:item_type]
  end

  def filtered_field
    return if h.params[:field].blank? || cannot_filter?

    h.params[:field]
  end

  def filterable_options
    @filterable_options ||=
      Rails.cache.fetch([:filterable_options, type_param], expires_in: 1.day) do
        sort_groupings(append_all_grouping(filterable_fields.deep_merge(filterable_types)))
      end
  end

  def sort_order
    h.params[:order] == 'asc' ? :asc : :desc
  end

  def rules_club_page_id
    RULES_CLUB_PAGE_IDS[type_param]
  end

private

  def apply_filters scope
    scope = scope.where user_id: filtered_user.id if filtered_user
    scope = scope.where moderator_id: filtered_moderator.id if filtered_moderator

    if filtered_item_type
      scope = scope.where(
        'item_type = :type or associated_type = :type',
        type: filtered_item_type
      )
    end

    scope = filter_by_fields scope if filtered_field

    scope
  end

  def filter_by_fields scope
    new_scope = filter_by_field scope, filtered_field

    (MERGED_FIELDS[filtered_field] || []).each do |field|
      new_scope = new_scope.or(filter_by_field(scope.scope, field))
    end

    new_scope
  end

  def filter_by_field scope, field
    if field[0].match?(/[[:upper:]]/)
      scope.where item_type: field
    else
      scope.where '(item_diff->>:field) is not null', field: field
    end
  end

  def sort_groupings filters
    filters.transform_values do |fields|
      fields.reject { |field| field.in? HIDDEN_FIELDS }.sort_by(&:second)
    end
  end

  def append_all_grouping filters
    {
      ALL_TYPES => filters.values.inject(&:merge),
      **filters
    }
  end

  def filterable_fields
    FILTERABLE_TYPES.index_with do |type|
      (
        Moderation::ProcessedVersionsQuery
          .fetch(type_param, nil)
          .except(:order)
          .where(item_type: type)
          .distinct
          .pluck(Arel.sql('jsonb_object_keys(item_diff)')) - IGNORED_FIELDS
      )
        .index_with { |key| type.constantize.human_attribute_name key }
    end
  end

  def filterable_types
    FILTERABLE_TYPES.index_with do |type|
      Moderation::ProcessedVersionsQuery
        .fetch(type_param, nil)
        .except(:order)
        .where(associated_type: type)
        .distinct
        .pluck(:item_type)
        .index_with { |item_type| item_type.constantize.model_name.human count: 1 }
    end
  end

  def cannot_filter?
    !h.can?(:filter, Version)
  end
end
