class AniMangaDecorator::RelatedDecorator < BaseDecorator
  instance_cache :related, :similar, :all, :similar_entries

  # связанные аниме
  def related
    all
      .map {|v| RelatedEntry.new (v.anime || v.manga).decorate, v.relation }
      #.sort_by {|v| v.relation == BaseMalParser::RelatedAdaptationName ? 0 : 1 }
  end

  # похожие аниме
  def similar
    if h.user_signed_in?
      rates = h.current_user.send("#{object.class.name.downcase}_rates")
        .where(target_id: similar_entries.map(&:id))
        .select(:target_id, :status)

      similar_entries.each do |entry|
        entry.in_list = rates.find {|v| v.target_id == entry.id }.try(:status)
      end

    else
      similar_entries
    end
  end

  # есть ли они вообще?
  def any?
    related.any?
  end

  # одно ли связанное аниме?
  def one?
    related.size == 1
  end

  # одно ли что-либо, кроме адаптаций?
  def chronology?
    related.any? {|v| v.relation.downcase != 'adaptation' }
  end

  # достаточно ли большое число связанных аниме?
  #def many?
    #related.size > AnimeDecorator::VISIBLE_RELATED
  #end

  def all
    object
      .related
      .includes(:anime, :manga)
      .select { |v| (v.anime_id && v.anime && v.anime.name) || (v.manga_id && v.manga && v.manga.name) }
      .sort_by do |v|
        (v.anime_id ? v.anime.aired_on : nil) ||
          (v.manga_id ? v.manga.aired_on : nil) ||
          Date.new(9999)
      end
  end

private

  def similar_entries
    object
      .similar
      .includes(:dst)
      .select {|v| v.dst && v.dst.name } # т.к.связанные аниме могут быть ещё не импортированы
      .map {|v| v.dst.decorate }
  end
end
