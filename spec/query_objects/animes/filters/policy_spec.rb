describe Animes::Filters::Policy do
  let(:params) do
    {
      achievement: achievement,
      censored: censored,
      franchise: franchise,
      genre: genre,
      ids: ids,
      kind: kind,
      mylist: mylist,
      studio: studio
    }
  end
  let(:achievement) { nil }
  let(:censored) { nil }
  let(:franchise) { nil }
  let(:genre) { nil }
  let(:ids) { nil }
  let(:kind) { nil }
  let(:mylist) { nil }
  let(:studio) { nil }

  let(:no_hentai) { Animes::Filters::Policy.exclude_hentai? params }
  let(:no_music) { Animes::Filters::Policy.exclude_music? params }

  it { expect(no_hentai).to eq true }
  it { expect(no_music).to eq true }

  describe 'censored' do
    context 'true' do
      let(:censored) { [true, 'true', 1, '1'].sample }

      it { expect(no_hentai).to eq true }
      it { expect(no_music).to eq true }
    end

    context 'false' do
      let(:censored) { [false, 'false', 0, '0'].sample }

      it { expect(no_hentai).to eq false }
      it { expect(no_music).to eq false }
    end
  end

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

  describe 'mylist' do
    let(:mylist) { 'zxc' }

    it { expect(no_hentai).to eq false }
    it { expect(no_music).to eq false }
  end
end
