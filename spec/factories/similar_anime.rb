FactoryGirl.define do
  factory :similar_anime do
    src_id { FactoryGirl.create(:anime).id }
    dst_id { FactoryGirl.create(:anime).id }
  end
end
