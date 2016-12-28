describe Import::PersonRoles do
  let(:service) { Import::PersonRoles.new target, similars, id_key }
  let(:target) { create :anime }
  let(:similars) do
    [
      {
        id: 28_735,
        type: :anime
      }, {
        id: 31_771,
        type: :anime
      }
    ]
  end
  let!(:similar_anime) do
    create :similar_anime,
      src_id: target.id,
      dst_id: 28_735
  end
  let(:id_key) { :character_id }

  subject! { service.call }

  it do
    expect { similar_anime.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(target.similar).to have(2).items
    expect(target.similar.first).to have_attributes(
      src_id: target.id,
      dst_id: 31_771
    )
    expect(target.similar.second).to have_attributes(
      src_id: target.id,
      dst_id: 28_735
    )
  end
end
