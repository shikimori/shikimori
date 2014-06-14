class MangaOnline::MangasDirector < BaseDirector
  include UsersHelper
  page :info

  def show
    append_title! HTMLEntities.new.decode(entry.russian) if entry.russian.present?
    append_title! entry.name

    noindex if entry.object[:description].blank? || entry.kind == 'Special'

    redirect!
  end

private
  def redirect?
    false
  end
end
