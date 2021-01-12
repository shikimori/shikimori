class Collections::TagsQuery
  method_object

  def call
    Collection
      .where(state: Types::Collection::State[:published])
      .distinct
      .pluck(Arel.sql('unnest(tags) as tag'))
      .sort
  end
end
