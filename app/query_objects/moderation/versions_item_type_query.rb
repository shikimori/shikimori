class Moderation::VersionsItemTypeQuery < QueryObjectBase
  Type = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(:all_content, :names, :texts, :fansub, :role, :videos, :images, :links, :content)

  OTHER_VERSION_TYPES = (Types::User::VERSION_ROLES - %i[version_moderator])
    .map { |v| Type[v.to_s.gsub(/^version_|_moderator$/, '')] }
  VERSION_TYPES = %i[content] + OTHER_VERSION_TYPES

  VERSION_NOT_MANAGED_FIELDS_SQL = Abilities::VersionModerator::NOT_MANAGED_FIELDS
    .map { |v| "(item_diff->>'#{v}') is null" }
    .join(' and ')
  DESYNCED_FIELDS = %w[desynced]

  def self.fetch type # rubocop:disable all
    scope = new Version.all

    case Type[type]
      when Type[:all_content]
        scope.non_roles

      when Type[:names]
        scope.non_roles.names

      when Type[:texts]
        scope.non_roles.texts

      when Type[:content]
        scope.non_roles.content

      when Type[:fansub]
        scope.non_roles.fansub

      when Type[:videos]
        scope.non_roles.videos

      when Type[:images]
        scope.non_roles.images

      when Type[:links]
        scope.non_roles.links

      when Type[:role]
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

  def content # rubocop:disable all
    chain(
      OTHER_VERSION_TYPES.inject(@scope) do |scope, type|
        moderator_ability_klass = "Abilities::Version#{type.to_s.capitalize}Moderator".constantize
        new_scope = scope
          .where.not(
            '(' +
            (moderator_ability_klass::MANAGED_FIELDS - DESYNCED_FIELDS)
              .map { |v| "(item_diff->>'#{v}') is not null" }
              .join(' or ') +
            ') and item_type in (' +
            moderator_ability_klass::MANAGED_FIELDS_MODELS
              .map { |v| ApplicationRecord.sanitize v }
              .join(', ') +
            ')'
          )

        if defined?(moderator_ability_klass::MANAGED_MODELS) &&
            moderator_ability_klass::MANAGED_MODELS.any?
          new_scope.where.not(item_type: moderator_ability_klass::MANAGED_MODELS)
        else
          new_scope
        end
      end
    )
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
