class Import::Recommendations
  method_object :target, :recommendations

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
    similar_klass.import build_recommendations
  end

  def build_recommendations
    @recommendations.map do |recommendation|
      similar_klass.new(
        src_id: @target.id,
        dst_id: recommendation[:id]
      )
    end
  end

  def similar_klass
    @target.is_a?(Anime) ? SimilarAnime : SimilarManga
  end
end
