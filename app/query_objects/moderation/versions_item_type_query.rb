class Moderation::VersionsItemTypeQuery < QueryObjectBase
  Types = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:all_content, :names, :texts, :content, :fansub, :role)

  VERSION_NOT_MANAGED_FIELDS_SQL = Abilities::VersionModerator::NOT_MANAGED_FIELDS
    .map { |v| "(item_diff->>'#{v}') is null" }
    .join(' and ')
  CONTENT_ONLY_FIELDS = %w[desynced image]

  def self.fetch type
    scope = new Version.all

    case Types[type]
      when Types[:all_content]
        scope.non_roles

      when Types[:texts]
        scope.non_roles.texts

      when Types[:names]
        scope.non_roles.names

      when Types[:content]
        scope.non_roles.content

      when Types[:fansub]
        scope.non_roles.fansub

      when Types[:role]
        scope.roles
    end
  end

  def roles
    chain @scope.where(type: Versions::RoleVersion.name)
  end

  def non_roles
    chain @scope.where('type is null or type != ?', Versions::RoleVersion.name)
  end

  def names
    chain @scope
      .where(
        (Abilities::VersionNamesModerator::MANAGED_FIELDS - CONTENT_ONLY_FIELDS)
          .map { |v| "(item_diff->>'#{v}') is not null" }
          .join(' or ')
      )
      .where(item_type: Abilities::VersionNamesModerator::MANAGED_MODELS)
  end

  def texts
    chain @scope
      .where(
        (Abilities::VersionTextsModerator::MANAGED_FIELDS - CONTENT_ONLY_FIELDS)
          .map { |v| "(item_diff->>'#{v}') is not null" }
          .join(' or ')
      )
      .where(item_type: Abilities::VersionTextsModerator::MANAGED_MODELS)
  end

  def content
    chain @scope.where(
      "(#{VERSION_NOT_MANAGED_FIELDS_SQL}) or item_type not in (?)",
      Abilities::VersionTextsModerator::MANAGED_MODELS
    )
  end

  def fansub
    chain @scope.where(
      (Abilities::VersionFansubModerator::MANAGED_FIELDS - CONTENT_ONLY_FIELDS)
        .map { |v| "(item_diff->>'#{v}') is not null" }
        .join(' or ')
    )
  end
end
