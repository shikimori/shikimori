class LogQueryComplexityAnalyzer < GraphQL::Analysis::AST::QueryComplexity
  def result
    complexity = super
    NamedLogger.graphql.info "[GraphQL Query Complexity] #{complexity}"
  end
end
