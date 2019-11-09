class Articles::TagsQuery
  method_object

  def call
    Article
      .where(state: Types::Article::State[:published])
      .distinct
      .pluck(Arel.sql('unnest(tags) as tag'))
      .sort
  end
end
