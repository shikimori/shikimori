class DbImport::Similarities
  method_object :target, :similarities

  def call
    klass.transaction do
      cleanup
      import
    end
  end

private

  def cleanup
    klass.where(src_id: @target.id).delete_all
  end

  def import
    klass.import build_similarities
  end

  def build_similarities
    @similarities.map do |recommendation|
      klass.new(
        src_id: @target.id,
        dst_id: recommendation[:id]
      )
    end
  end

  def klass
    @target.is_a?(Anime) ? SimilarAnime : SimilarManga
  end
end
