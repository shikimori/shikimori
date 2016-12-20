describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:id) { 987_654_321 }
  let(:data) do
    {
      id: id,
      name: 'Test test 2'
    }
  end

  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
  end
end
