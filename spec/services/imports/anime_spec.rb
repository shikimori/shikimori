describe Imports::Anime do
  let(:service) { Imports::Anime.new data }
  let(:id) { 987654321 }
  let(:data) do
    {
      id: id,
      name: 'Test test 2'
    }
  end

  subject! { service.call }

  it do
  end
end
