class Animes::Filters::Kind
  method_object :scope, :value

  def call
    kinds = @value
      .split(',')
      .each_with_object(complex: [], simple: []) do |kind, memo|
        memo[kind.match?(/tv_\d+/) ? :complex : :simple] << kind
      end

    simple_kinds = bang_split kinds[:simple]

    simple_queries = {
      include: simple_kinds[:include]
        .delete_if { |v| v == 'tv' && kinds[:complex].any? { |q| q =~ /^tv_/ } }
        .map { |v| "#{table_name}.kind = #{ApplicationRecord.sanitize v}" },
      exclude: simple_kinds[:exclude]
        .map { |v| "#{table_name}.kind = #{ApplicationRecord.sanitize v}" }
    }
    complex_queries = { include: [], exclude: [] }

    kinds[:complex].each do |kind|
      with_bang = kind.starts_with? '!'

      query = case kind
        when 'tv_13', '!tv_13'
          "(#{table_name}.kind = 'tv' and episodes != 0 and episodes <= 16) or (#{table_name}.kind = 'tv' and episodes = 0 and episodes_aired <= 16)"

        when 'tv_24', '!tv_24'
          "(#{table_name}.kind = 'tv' and episodes != 0 and episodes >= 17 and episodes <= 28) or (#{table_name}.kind = 'tv' and episodes = 0 and episodes_aired >= 17 and episodes_aired <= 28)"

        when 'tv_48', '!tv_48'
          "(#{table_name}.kind = 'tv' and episodes != 0 and episodes >= 29) or (#{table_name}.kind = 'tv' and episodes = 0 and episodes_aired >= 29)"
      end

      complex_queries[with_bang ? :exclude : :include] << query
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
end
