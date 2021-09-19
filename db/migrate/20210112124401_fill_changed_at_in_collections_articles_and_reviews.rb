class FillChangedAtInCollectionsArticlesAndReviews < ActiveRecord::Migration[5.2]
  def change
    execute %q[
      update collections set changed_at = updated_at where changed_at is null;
    ]
    execute %q[
      update critiques set changed_at = updated_at where changed_at is null;
    ]
    execute %q[
      update articles set changed_at = updated_at where changed_at is null;
    ]
  end
end
