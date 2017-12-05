FactoryBot.define do
  factory :similar_manga do
    src_id { FactoryBot.create(:manga).id }
    dst_id { FactoryBot.create(:manga).id }
  end
end
