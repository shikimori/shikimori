class Import::PersonRoles
  method_object :target, :similars, :id_key

  def call
    similar_klass.transaction do
      cleanup
      import
    end
  end

private

  def cleanup
    similar_klass.where(src_id: @target.id).delete_all
  end

  def import
    similar_klass.import build_similars
  end

  def build_similars
    @similars.map do |similar|
      similar_klass.new(
        src_id: @target.id,
        dst_id: similar[:id]
      )
    end
  end

  def similar_klass
    @target.is_a?(Anime) ? SimilarAnime : SimilarManga
  end
end
