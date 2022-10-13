class FixClubRanobeExternalLinks < ActiveRecord::Migration[6.1]
  def up
    ClubLink
      .where(linked_type: 'Manga') .joins('left join mangas on mangas.id = linked_id')
      .where(mangas: { type: 'Ranobe' })
      .find_each do |club_link|
        puts club_link.id
        club_link.update! linked_type: 'Ranobe'
      rescue ActiveRecord::RecordInvalid
        club_link.destroy!
      end
  end
end
