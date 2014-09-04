class AniMangaDecorator::ChangesDecorator < BaseDecorator
  def [](field)
    @changes ||= {}
    @changes[field.to_s] ||= UserChangesQuery.new(object, field).fetch
  end

  def authors(field, with_taken = true)
    @authors ||= {}
    @authors[field.to_s + with_taken.to_s] ||= UserChangesQuery.new(object, field).authors with_taken
  end

  def locked?
    lock.present?
  end

  def lock
    @lock ||= UserChangesQuery.new(object, :description).lock
  end
end
