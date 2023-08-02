class LogQueryComplexityAnalyzer < GraphQL::Analysis::AST::QueryComplexity
  def result
    complexity = super
    NamedLogger.graphql.info "[Complexity] #{complexity}"
  end
end
