describe Summary::Create do
  subject(:summary) { described_class.call params }

  let(:anime) { create :anime, :released, released_on: released_on }
  let(:released_on) { nil }
  let(:params) do
    {
      anime_id: anime.id,
      body: body,
      tone: 'positive',
      user: user
    }
  end
  let(:body) { 'a' * Summary::MIN_BODY_SIZE }
  let(:released_on) do
    [
      1.day.ago,
      1.day.from_now
    ].sample
  end

  it do
    expect(subject).to be_persisted
    expect(subject).to have_attributes(
      anime_id: anime.id,
      body: body,
      tone: 'positive',
      user: user,
      is_written_before_release: released_on > Time.zone.now
    )
  end
end
