module LogQueryInstrumentation
  def self.before_query query
    NamedLogger.graphql.info "[Query] #{query.query_string}"
    NamedLogger.graphql.info "[Variables] #{query.provided_variables.to_json}"
  end

  def self.after_query _query
  end
end
