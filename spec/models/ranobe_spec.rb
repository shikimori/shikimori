describe Ranobe do
  it_behaves_like :touch_related_in_db_entry, :ranobe
  it_behaves_like :topics_concern, :ranobe
  it_behaves_like :collections_concern, :ranobe
  it_behaves_like :clubs_concern, :ranobe
end
