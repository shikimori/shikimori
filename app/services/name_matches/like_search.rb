class NameMatches::LikeSearch < ServiceObjectBase
  vattr_initialize :scope, :phrase

  JOIN_ALIAS = 'name_matches'

  def call
    @scope
      .joins(Arel.sql(join_sql))
      .order(Arel.sql('name_matches.group, name_matches.phrase'))
  end

private

  def join_sql
    <<-SQL.strip
      inner join (#{name_match_query.to_sql}) #{JOIN_ALIAS} on
        #{JOIN_ALIAS}.target_id = #{@scope.table_name}.id
    SQL
  end

  def name_match_query
    NameMatch
      .where(target_type: @scope.model.name)
      .where("phrase like #{ApplicationRecord.sanitize "#{fixed_phrase}%"}")
      .group(:target_id)
      .select("
        #{NameMatch.table_name}.target_id,
        min(#{NameMatch.table_name}.phrase) as phrase,
        min(#{NameMatch.table_name}.group) as group
      ")
  end

  def fixed_phrase
    cleaner.finalize cleaner.cleanup(@phrase)
  end

  def cleaner
    NameMatches::Cleaner.instance
  end
end
