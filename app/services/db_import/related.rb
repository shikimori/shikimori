class DbImport::Related
  method_object :target, :related

  RELATIONS = MalParser::Entry::Anime::RELATED.invert

  def call
    klass.transaction do
      cleanup
      import
    end
  end

private

  def cleanup
    klass.where(source_id: @target.id).delete_all
  end

  def import
    klass.import build_relations
  end

  def build_relations
    @related.flat_map do |relation, related_datas|
      related_datas.map do |related_data|
        relation_kind = Types::RelatedAniManga::RelationKind[relation]
        klass.new(
          source_id: @target.id,
          anime_id: (related_data[:id] if related_data[:type] == :anime),
          manga_id: (related_data[:id] if related_data[:type] == :manga),
          relation_kind:
        )
      end
    end
  end

  def klass
    @target.is_a?(Anime) ? RelatedAnime : RelatedManga
  end

  def extract_relation relation
    RELATIONS[relation] || raise("unexpected relation #{relation}")
  end
end
