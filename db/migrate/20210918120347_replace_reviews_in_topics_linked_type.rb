class ReplaceReviewsInTopicsLinkedType < ActiveRecord::Migration[5.2]
  def up
    Topic.where(linked_type: 'Review').update_all linked_type: 'Critique'
  end

  def down
    Topic.where(linked_type: 'Critique').update_all linked_type: 'Review'
  end
end
