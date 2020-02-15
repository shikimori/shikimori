class Animes::Filters::OrderBy < Animes::Filters::FilterBase # rubocop:disable ClassLength
  method_object :scope, :value

  Field = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(
      :name,
      :russian,
      :episodes,
      :chapters,
      :volumes,
      :status,
      :popularity,
      :ranked,
      :released_on,
      :aired_on,
      :id,
      :id_desc,
      :rate_id,
      :rate_updated,
      :my, :rate,
      :site_score,
      :kind, # :type
      :user_1,
      :user_2,
      :random
    )

  dry_type Field

  DEFAULT_ORDER = Field[:ranked]

  ORDER_SQL = {
    Field[:name] => '%<table_name>s.name',
    Field[:russian] => '%<table_name>s.russian, %<table_name>s.name',
    Field[:episodes] => (
      <<-SQL.squish
        (case
          when %<table_name>s.episodes = 0
          then %<table_name>s.episodes_aired
          else %<table_name>s.episodes
        end) desc
      SQL
    ),
    Field[:chapters] => '%<table_name>s.chapters desc',
    Field[:volumes] => '%<table_name>s.volumes desc',
    Field[:status] => '%<table_name>s.status',
    Field[:popularity] => (
      <<-SQL.squish
        (case
          when %<table_name>s.popularity = 0
          then 999999
          else %<table_name>s.popularity
        end)
      SQL
    ),
    Field[:ranked] => (
      <<-SQL.squish
        (case
          when %<table_name>s.ranked = 0
          then 999999
          else %<table_name>s.ranked
        end), %<table_name>s.score desc
      SQL
    ),
    Field[:released_on] => (
      <<-SQL.squish
        (case
          when %<table_name>s.released_on is null
          then %<table_name>s.aired_on
          else %<table_name>s.released_on
        end) desc
      SQL
    ),
    Field[:aired_on] => '%<table_name>s.aired_on desc',
    Field[:id] => '%<table_name>s.id',
    Field[:id_desc] => '%<table_name>s.id desc',
    Field[:rate_id] => 'user_rates.id',
    Field[:rate_updated] => 'user_rates.updated_at desc, user_rates.id',
    Field[:my] => (
      <<-SQL.squish
        user_rates.score desc,
        %<table_name>s.name,
        %<table_name>s.id
      SQL
    ),
    Field[:site_score] => '%<table_name>s.site_score desc',
    Field[:kind] => '%<table_name>s.kind',
    Field[:random] => 'random()'
  }

  ORDER_SQL[Field[:rate]] = Field[:my]

  CUSTOM_SORTINGS = [
    [Field[:user_1]],
    [Field[:user_2]]
  ]

  def call
    return @scope if custom_sorting?

    fail_with_negative! if negatives.any?

    @scope.order Arel.sql(terms_sql)
  end

private

  def terms_sql
    sort_fields
      .map { |term| term_sql term }
      .join(',')
  end

  def term_sql term
    format ORDER_SQL[term], table_name: @scope.table_name
  end

  def sort_fields
    (
      (positives.any? ? positives : [DEFAULT_ORDER]) + [Field[:id]]
    ).uniq
  end

  def custom_sorting?
    CUSTOM_SORTINGS.include? positives
  end
end
