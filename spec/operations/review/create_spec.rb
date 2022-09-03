describe Review::Create do
  subject(:review) { described_class.call params }

  let(:anime) do
    create :anime, :released, released_on: released_on, is_censored: is_censored
  end
  let(:released_on) { nil }
  let(:is_censored) { [true, false].sample }
  let(:params) do
    {
      anime_id: anime.id,
      body: body,
      opinion: 'positive',
      user: user
    }
  end
  let(:body) { 'a' * Review::MIN_BODY_SIZE }
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
      opinion: 'positive',
      user: user,
      is_written_before_release: released_on > Time.zone.now
    )
    expect(review.topics).to have(1).item
    expect(review.topics.first.is_censored).to eq is_censored
  end
end
