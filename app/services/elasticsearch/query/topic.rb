class Elasticsearch::Query::Topic < Elasticsearch::Query::QueryBase
  method_object %i[phrase! forum_id! limit!]

private

  def query
    {
      bool: {
        must: [super, forum_id_query]
      }
    }
  end

  def forum_id_query
    if @forum_id.is_a? Array
      {
        bool: {
          should: @forum_id.map { |forum_id| { term: { forum_id: forum_id } } }
        }
      }
    else
      { term: { forum_id: @forum_id } }
    end
  end
end
