class Menus::CollectionMenu < ViewObjectBase
  vattr_initialize :klass

  def url
    h.send "menu_#{klass.name.tableize}_url", rating: h.params[:rating]
  end

  def sorted_genres
    genres.sort_by { |v| [v.position || v.id, h.localized_name(v)] }
  end

  def genres
    "#{klass.base_class.name}GenresRepository".constantize.instance.to_a
  end

  def studios
    StudiosRepository.instance.to_a
  end

  def publishers
    PublishersRepository.instance.to_a
  end

  def licensors
    @licensors ||= LicensorsRepository.instance.send @klass.name.downcase
  end

  def kinds
    allowed_kinds.map { |kind| Titles::KindTitle.new kind, klass }
  end

  def statuses
    [
      Titles::StatusTitle.new(:anons, klass),
      Titles::StatusTitle.new(:ongoing, klass),
      Titles::StatusTitle.new(:released, klass),
      Titles::StatusTitle.new(:latest, klass),
      (Titles::StatusTitle.new(:paused, klass) if klass != Anime),
      (Titles::StatusTitle.new(:discontinued, klass) if klass != Anime)
    ].compact
  end

  def seasons # rubocop:disable all
    [
      Titles::SeasonTitle.new(3.months.from_now, :season_year, klass),
      Titles::SeasonTitle.new(Time.zone.now, :season_year, klass),
      Titles::SeasonTitle.new(3.months.ago, :season_year, klass),
      Titles::SeasonTitle.new(6.months.ago, :season_year, klass),
      Titles::SeasonTitle.new(Time.zone.now, :year, klass),
      Titles::SeasonTitle.new(1.year.ago, :year, klass),
      Titles::SeasonTitle.new(2.years.ago, :years_2, klass),
      Titles::SeasonTitle.new(4.years.ago, :years_5, klass),
      Titles::SeasonTitle.new(
        9.years.ago,
        :"years_#{Time.zone.today.year - 2000 - 8}",
        klass
      ),
      Titles::SeasonTitle.new(Date.parse('1995-01-01'), :decade, klass),
      Titles::SeasonTitle.new(Date.parse('1985-01-01'), :decade, klass),
      Titles::SeasonTitle.new(nil, :ancient, klass)
    ]
  end

  def show_sorting?
    h.params[:controller] != 'recommendations' &&
      h.params[:search].blank? && h.params[:q].blank?
  end

  def anime?
    klass == Anime
  end

  def ranobe?
    klass == Ranobe
  end

private

  def allowed_kinds
    if h.params[:controller] == 'user_rates'
      klass.kind.values
    elsif klass == Ranobe
      Ranobe::KINDS
    else
      klass.kind.values - Ranobe::KINDS
    end
  end
end
