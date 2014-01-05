class ChronologyQuery
  def initialize entry, with_specials
    @entry = entry
    @with_specials = with_specials
  end

  def fetch
    relations = fetch_related [@entry.id], {}

    future = DateTime.now + 10.years
    @entry.class.where(id: relations.keys)
        .sort_by { |v| [v.aired_at || future, v.id] }
        .reverse
  end

private
  def related_klass
    @entry.anime? ? RelatedAnime : RelatedManga
  end

  def related_field
    @entry.anime? ? :anime_id : :manga_id
  end

  def bad_relations
    if @entry.manga?
      [20566,25482,13721,27327]
    else
      [6115, 17819,17791,17815,17813,17811,13309,13529,13375,13373]
    end
  end

  def fetch_related ids, relations
    ids_to_fetch = ids - relations.keys

    fetched_ids = groupped_relation(ids_to_fetch).map do |source_id, group|
      relations[source_id] = bad_relations.include?(source_id) ? [] : group

      relations[source_id]
        .select { |v| v.relation != 'Character' }
        .map { |v| v.send related_field }
    end.flatten

    if fetched_ids.any?
      fetch_related fetched_ids, relations
    else
      relations
    end
  end

  def groupped_relation ids
    query = related_klass
      .where(source_id: ids)
      .where("#{related_field} is not null")

    unless @with_specials
      query = query.joins("
        inner join #{@entry.class.table_name} on
          #{@entry.class.table_name}.id=#{@entry.class.name.downcase}_id
          and #{@entry.class.table_name}.kind != 'Special'
        ")
    end

    query.all.group_by(&:source_id)
  end
end
