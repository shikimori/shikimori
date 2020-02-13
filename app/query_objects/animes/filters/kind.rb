class Animes::Filters::Kind
  include Animes::Filters::Helpers
  method_object :scope, :term

  TV_13_SQL = <<~SQL.squish
    (
      %<table_name>s.kind = 'tv' and (
        (episodes != 0 and episodes <= 16) or
        (episodes = 0 and episodes_aired <= 16)
      )
    )
  SQL

  TV_24_SQL = <<~SQL.squish
    (
      %<table_name>s.kind = 'tv' and (
        (episodes != 0 and episodes >= 17 and episodes <= 28) or
        (episodes = 0 and episodes_aired >= 17 and episodes_aired <= 28)
      )
    )
  SQL

  TV_48_SQL = <<~SQL.squish
    (
      %<table_name>s.kind = 'tv' and (
        (episodes != 0 and episodes >= 29) or
        (episodes = 0 and episodes_aired >= 29)
      )
    )
  SQL

  def call
    kinds[:complex].each do |kind|
      with_bang = kind.starts_with? '!'

      query_template =
        case kind
          when 'tv_13', '!tv_13' then TV_13_SQL
          when 'tv_24', '!tv_24' then TV_24_SQL
          when 'tv_48', '!tv_48' then TV_48_SQL
        end

      complex_queries[with_bang ? :exclude : :include].push(
        format(query_template, table_name: table_name)
      )
    end

    includes = (simple_queries[:include] + complex_queries[:include]).compact
    excludes = (simple_queries[:exclude] + complex_queries[:exclude]).compact

    scope = @scope
    if includes.any?
      scope = scope.where includes.join(' or ')
    end

    if excludes.any?
      scope = scope.where 'not(' + excludes.join(' or ') + ')'
    end
    scope
  end

private

  def kinds
    @kinds ||= @term
      .split(',')
      .each_with_object(complex: [], simple: []) do |kind, memo|
        memo[kind.match?(/tv_\d+/) ? :complex : :simple] << kind
      end
  end

  def simple_kinds
    @simple_kinds ||= bang_split kinds[:simple]
  end

  def simple_queries
    @simple_queries ||= {
      include: simple_kinds[:include]
        .delete_if { |term| term == 'tv' && kinds[:complex].any? { |q| q =~ /^tv_/ } }
        .map { |term| "#{table_name}.kind = #{sanitize term}" },
      exclude: simple_kinds[:exclude]
        .map { |term| "#{table_name}.kind = #{sanitize term}" }
    }
  end

  def complex_queries
    @complex_queries ||= {
      include: [],
      exclude: []
    }
  end
end
