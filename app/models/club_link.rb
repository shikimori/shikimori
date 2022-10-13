class ClubLink < ApplicationRecord
  belongs_to :club, touch: true
  belongs_to :linked, polymorphic: true

  validates :club_id, uniqueness: { scope: %i[linked_id linked_type] }
  before_save :ensure_ranobe_linked_type,
    if: :will_save_change_to_linked_type?

private

  def ensure_ranobe_linked_type
    if linked_type == 'Manga' && linked.instance_of?(Ranobe)
      self.linked_type = 'Ranobe'
    end
  end
end
