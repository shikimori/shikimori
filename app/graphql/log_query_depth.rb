class LogQueryDepth < GraphQL::Analysis::AST::QueryDepth
  def result
    query_depth = super
    NamedLogger.graphql.info "[GraphQL Query Depth] #{query_depth}"
  end
end
