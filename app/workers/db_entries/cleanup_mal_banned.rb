class DbEntries::CleanupMalBanned
  include Sidekiq::Worker

  def perform
    cleanup_banned_roles

    [Anime, Manga, Ranobe, Character, Person].each do |klass|
      cleanup_banned_entries klass
    end
  end

private

  def cleanup_banned_roles
    if PersonRole.where(banned_roles_sql).size > DbImport::BannedRoles.instance.config.size
      raise ArgumentError, 'broken banned_mal_roles config'
    end

    PersonRole.where(banned_roles_sql).destroy_all
  end

  def banned_roles_sql
    DbImport::BannedRoles.instance.config.map { |role| role_to_sql(role) }.join(' or ')
  end

  def role_to_sql role
    '(' + role_conditions(role).join(' and ') + ')'
  end

  def role_conditions role
    role.map do |key, value|
      raise ArgumentError, 'bad column name' unless PersonRole.column_names.include? key

      "#{key} = #{ApplicationRecord.sanitize value}"
    end
  end

  def cleanup_banned_entries klass
    klass.where(id: DbImport::BannedIds.instance.config[klass.name.downcase.to_sym]).destroy_all
  end
end
