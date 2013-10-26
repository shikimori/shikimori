FactoryGirl.define do
  factory :similar_manga do
    src_id { FactoryGirl.create(:manga).id }
    dst_id { FactoryGirl.create(:manga).id }
  end
end
