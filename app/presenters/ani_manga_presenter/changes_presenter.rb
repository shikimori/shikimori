class AniMangaPresenter::ChangesPresenter < BasePresenter
  def [](field)
    @changes ||= {}
    @changes[field.to_s] ||= UserChangesQuery.new(entry, field).fetch
  end

  def authors(field, with_taken = true)
    @authors ||= {}
    @authors[field.to_s + with_taken.to_s] ||= UserChangesQuery.new(entry, field).authors with_taken
  end

  def locked?
    lock.present?
  end

  def lock
    @lock ||= UserChangesQuery.new(entry, :description).lock
  end
end
