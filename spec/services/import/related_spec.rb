describe Import::Related do
  let(:service) { Import::Related.new target, related }
  let(:target) { create :anime }
  let(:related) do
    {
      adaptation: [{
        id: 21_479,
        type: :manga,
        name: 'Sword Art Online'
      }],
      other: [{
        id: 16_099,
        type: :anime,
        name: 'Sword Art Online: Sword Art Offline'
      }]
    }
  end
  let!(:related_anime) do
    create :related_anime,
      source_id: target.id,
      relation: 'Adaptation',
      manga_id: 21_479
  end

  subject! { service.call }
  let(:new_related) { target.related.order :id }

  it do
    expect { related_anime.reload }.to raise_error ActiveRecord::RecordNotFound
    expect(new_related).to have(2).items
    expect(new_related.first).to have_attributes(
      anime_id: nil,
      manga_id: 21_479,
      relation: 'Adaptation',
      source_id: target.id
    )
    expect(new_related.second).to have_attributes(
      anime_id: 16_099,
      manga_id: nil,
      relation: 'Other',
      source_id: target.id
    )
  end
end
