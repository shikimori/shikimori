describe Summary::Update do
  subject { described_class.call summary, params }

  let(:summary) do
    create :summary,
      user: user,
      anime: anime,
      is_written_before_release: true
  end
  let(:anime) { create :anime, :released, released_on: released_on }
  let(:released_on) { nil }

  let(:params) do
    {
      body: body,
      is_written_before_release: is_written_before_release
    }
  end
  let(:is_written_before_release) { false }

  context 'valid update' do
    let(:body) { 'b' * Summary::MIN_BODY_SIZE }

    context 'can change is_written_before_release' do
      let(:released_on) { Time.zone.today }

      it do
        is_expected.to eq true
        expect(summary).to have_attributes(
          body: body,
          is_written_before_release: is_written_before_release
        )
      end
    end

    context 'cannot change is_written_before_release' do
      let(:released_on) { Time.zone.tomorrow }

      it do
        is_expected.to eq true
        expect(summary).to have_attributes(
          body: body,
          is_written_before_release: true
        )
      end
    end
  end

  context 'invalid update' do
    let(:body) { 'b' * (Summary::MIN_BODY_SIZE - 1) }
    it { is_expected.to eq false }
  end
end
