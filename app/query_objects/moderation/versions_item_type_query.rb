class Moderation::VersionsItemTypeQuery < QueryObjectBase
  Types = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:all_content, :names, :texts, :content, :fansub, :role, :videos, :images, :links)

  VERSION_NOT_MANAGED_FIELDS_SQL = Abilities::VersionModerator::NOT_MANAGED_FIELDS
    .map { |v| "(item_diff->>'#{v}') is null" }
    .join(' and ')
  DESYNCED_FIELDS = %w[desynced]

  def self.fetch type # rubocop:disable all
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

      when Types[:videos]
        scope.non_roles.videos

      when Types[:images]
        scope.non_roles.images

      when Types[:links]
        scope.non_roles.links

      when Types[:role]
        scope.roles

      else
        scope
    end
  end

  def roles
    chain @scope.where(type: Versions::RoleVersion.name)
  end

  def non_roles
    chain @scope.where('type is null or type != ?', Versions::RoleVersion.name)
  end

  def names
    chain moderator_fields_scope(scope, Abilities::VersionNamesModerator)
  end

  def texts
    chain moderator_fields_scope(scope, Abilities::VersionTextsModerator)
  end

  def content
    chain @scope.where(
      "(#{VERSION_NOT_MANAGED_FIELDS_SQL}) or item_type not in (?)",
      Abilities::VersionTextsModerator::MANAGED_FIELDS_MODELS
    )
  end

  def fansub
    chain moderator_fields_scope(scope, Abilities::VersionFansubModerator)
  end

  def videos
    chain moderator_fields_scope(scope, Abilities::VersionVideosModerator)
  end

  def images
    chain moderator_fields_scope(scope, Abilities::VersionImagesModerator)
  end

  def links
    chain moderator_fields_scope(scope, Abilities::VersionLinksModerator)
  end

private

  def moderator_fields_scope scope, moderator_ability_klass
    new_scope = scope
      .where(
        (moderator_ability_klass::MANAGED_FIELDS - DESYNCED_FIELDS)
          .map { |v| "(item_diff->>'#{v}') is not null" }
          .join(' or ')
      )
      .where(item_type: moderator_ability_klass::MANAGED_FIELDS_MODELS)

    if defined?(moderator_ability_klass::MANAGED_MODELS) &&
        moderator_ability_klass::MANAGED_MODELS.any?
      new_scope.or(scope.where(item_type: moderator_ability_klass::MANAGED_MODELS))
    else
      new_scope
    end
  end
end
