class Animes::Filters::ByKind < Animes::Filters::FilterBase
  EXTENDED = %i[tv_13 tv_24 tv_48]
  KINDS_EXTENDED = Types::Anime::KINDS + EXTENDED

  KindExtended = Types::Strict::Symbol
    .constructor(&:to_sym)
    .enum(*KINDS_EXTENDED)

  dry_type KindExtended

  SQL_QUERIES = {
    KindExtended[:tv_13] => (
      <<~SQL.squish
        (
          %<table_name>s.kind = 'tv' and (
            (episodes != 0 and episodes <= 16) or
            (episodes = 0 and episodes_aired <= 16)
          )
        )
      SQL
    ),
    KindExtended[:tv_24] => (
      <<~SQL.squish
        (
          %<table_name>s.kind = 'tv' and (
            (episodes != 0 and episodes >= 17 and episodes <= 28) or
            (episodes = 0 and episodes_aired >= 17 and episodes_aired <= 28)
          )
        )
      SQL
    ),
    KindExtended[:tv_48] => <<~SQL.squish
      (
        %<table_name>s.kind = 'tv' and (
          (episodes != 0 and episodes >= 29) or
          (episodes = 0 and episodes_aired >= 29)
        )
      )
    SQL

  }

  def call
    terms_by_kind = build_kinds
    simple_queries = build_simple_queries terms_by_kind
    complex_queries = build_complex_queries terms_by_kind

    apply_scopes(
      (simple_queries[:includes] + complex_queries[:includes]).compact,
      (simple_queries[:excludes] + complex_queries[:excludes]).compact
    )
  end

private

  def apply_scopes includes, excludes
    scope = @scope

    if includes.any?
      scope = scope.where includes.join(' or ')
    end

    if excludes.any?
      scope = scope.where 'not(' + excludes.join(' or ') + ')'
    end

    scope
  end

  def build_kinds
    terms.each_with_object(complex: [], simple: []) do |term, memo|
      memo[EXTENDED.include?(term.value) ? :complex : :simple] << term
    end
  end

  def build_simple_queries terms_by_kind
    includes = terms_by_kind[:simple].reject do |term|
      term.is_negative ||
        term.value == KindExtended[:tv] &&
          terms_by_kind[:complex].any? { |q| EXTENDED.include? q.value }
    end
    excludes = terms_by_kind[:simple].select(&:is_negative)

    {
      includes: includes.map { |term| "#{table_name}.kind = #{sanitize term.value}" },
      excludes: excludes.map { |term| "#{table_name}.kind = #{sanitize term.value}" }
    }
  end

  def build_complex_queries terms_by_kind
    complex_queries = { includes: [], excludes: [] }

    terms_by_kind[:complex].each do |term|
      key = term.is_negative ? :excludes : :includes
      complex_queries[key].push(
        format(SQL_QUERIES[term.value], table_name: table_name)
      )
    end

    complex_queries
  end
end
