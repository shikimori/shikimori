class AniMangaPresenter::RelatedPresenter < BasePresenter
  # адаптации аниме
  def adaptations
    @adaptations ||= related_entries.select do |v|
      v.relation == BaseMalParser::RelatedAdaptationName
    end
  end

  # связанные аниме
  def all
    @related ||= related_entries.select do |v|
      v.relation != BaseMalParser::RelatedAdaptationName
    end
  end

  # похожие аниме
  def similar
    @similar ||= entry
      .similar
      .includes(:dst)
      .select {|v| v.dst && v.dst.name } # т.к.связанные аниме могут быть ещё не импортированы
      .map(&:dst)
  end

  # есть ли они вообще?
  def any?
    all.any?
  end

  # одно ли связанное аниме?
  def one?
    all.size == 1
  end

  # достаточно ли большое число связанных аниме?
  def many?
    all.size > 3
  end

private
  def related_entries
    @all_realted ||= entry
      .related
      .includes(:anime, :manga)
      .select { |v| (v.anime_id && v.anime && v.anime.name) || (v.manga_id && v.manga && v.manga.name) }
      .sort_by do |v|
        (v.anime_id ? v.anime.aired_on : nil) ||
          (v.manga_id ? v.manga.aired_on : nil) ||
          Date.new(9999)
      end
  end
end
