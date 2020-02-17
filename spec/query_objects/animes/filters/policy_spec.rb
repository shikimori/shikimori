describe Animes::Filters::Policy do
  let(:params) do
    {
      censored: censored,
      genre: genre,
      franchise: franchise,
      achievement: achievement,
      studio: studio,
      ids: ids,
      kind: kind
    }
  end
  let(:censored) { nil }
  let(:genre) { nil }
  let(:franchise) { nil }
  let(:achievement) { nil }
  let(:studio) { nil }
  let(:ids) { nil }
  let(:kind) { nil }

  let(:no_hentai) { Animes::Filters::Policy.exclude_hentai? params }
  let(:no_music) { Animes::Filters::Policy.exclude_music? params }

  it { expect(no_hentai).to eq true }
  it { expect(no_music).to eq true }

  describe 'kind' do
    context 'music' do
      let(:kind) do
        [
          Types::Anime::Kind[:music],
          'music',
          'tv,music'
        ].sample
      end

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq false }
    end

    context 'not music' do
      let(:kind) do
        [
          nil,
          'tv',
          '!music',
          'tv,!music'
        ].sample
      end

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq true }
    end
  end
end
