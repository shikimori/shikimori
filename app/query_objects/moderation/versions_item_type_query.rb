class Moderation::VersionsItemTypeQuery
  method_object :type

  Types = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:all_content, :texts, :content, :fansub, :role)

  VERSION_NOT_MANAGED_FIELDS_SQL = Abilities::VersionModerator::NOT_MANAGED_FIELDS
    .map { |v| "(item_diff->>'#{v}') is null" }
    .join(' and ')

  def call
    scope = Version.all

    case Types[type]
      when Types[:all_content]
        non_roles_scope(scope)

      when Types[:texts]
        texts_scope non_roles_scope(scope)

      when Types[:content]
        content_scope non_roles_scope(scope)

      when Types[:fansub]
        fansub_scope non_roles_scope(scope)

      when Types[:role]
        roles_scope(scope)
    end
  end

private

  def roles_scope scope
    scope.where(type: Versions::RoleVersion.name)
  end

  def non_roles_scope scope
    scope.where('type is null or type != ?', Versions::RoleVersion.name)
  end

  def texts_scope scope
    scope
      .where(
        Abilities::VersionTextsModerator::MANAGED_FIELDS
          .map { |v| "(item_diff->>'#{v}') is not null" }
          .join(' or ')
      )
      .where(item_type: Abilities::VersionTextsModerator::MANAGED_MODELS)
  end

  def content_scope scope
    scope.where(
      "(#{VERSION_NOT_MANAGED_FIELDS_SQL}) or item_type not in (?)",
      Abilities::VersionTextsModerator::MANAGED_MODELS
    )
  end

  def fansub_scope scope
    scope.where(
      Abilities::VersionFansubModerator::MANAGED_FIELDS
        .map { |v| "(item_diff->>'#{v}') is not null" }
        .join(' or ')
    )
  end
end
