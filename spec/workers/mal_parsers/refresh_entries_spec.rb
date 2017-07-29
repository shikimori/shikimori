describe MalParsers::RefreshEntries do
  let(:worker) { MalParsers::RefreshEntries.new }
  let(:type) { 'anime' }
  let(:status) { :ongoing }
  let(:refresh_interval) { '123' }

  let!(:released) { create :anime, :released }
  let!(:ongoing_1) { create :anime, :ongoing }
  let!(:ongoing_2) { create :anime, :ongoing }
  let!(:anons) { create :anime, :anons }

  before { allow(DbImport::Refresh).to receive :call }
  subject! { worker.perform type, status, refresh_interval }

  it do
    expect(DbImport::Refresh)
      .to have_received(:call)
      .with Anime, [ongoing_1.id, ongoing_2.id], refresh_interval.to_i
  end
end
