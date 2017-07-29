describe DbImport::Similarities do
  let(:service) { DbImport::Similarities.new target, similarities }
  let(:target) { create :anime }
  let(:similarities) do
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
  let(:new_similarities) { target.similar.order :id }

  subject! { service.call }

  it do
    expect { similar_anime.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(new_similarities).to have(2).items
    expect(new_similarities.first).to have_attributes(
      src_id: target.id,
      dst_id: 28_735
    )
    expect(new_similarities.second).to have_attributes(
      src_id: target.id,
      dst_id: 31_771
    )
  end
end
