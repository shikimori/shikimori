describe Import::Anime do
  let(:service) { Import::Anime.new data }
  let(:id) { 987_654_321 }
  let(:data) do
    {
      id: id,
      name: 'Test test 2'
    }
  end

  subject { service.call }

  it do
    expect { subject }.to change(Anime, :count).by 1
  end
end
