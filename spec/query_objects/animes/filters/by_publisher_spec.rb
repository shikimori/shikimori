describe Animes::Filters::ByPublisher do
  subject { described_class.call scope, terms }

  let(:scope) { Manga.order :id }

  let(:kakao) { create :publisher, id: 206 }
  let(:kakao_clone) { create :publisher, id: 81 }
  let(:naver) { create :publisher }

  let!(:manga_1) { create :manga, publisher_ids: [kakao.id, naver.id] }
  let!(:manga_2) { create :manga, publisher_ids: [kakao.id] }
  let!(:manga_3) { create :manga, publisher_ids: [kakao_clone.id] }
  let!(:manga_4) { create :manga }
  let!(:manga_5) { create :manga, publisher_ids: [naver.id] }

  context 'positive' do
    context 'kakao' do
      let(:terms) { kakao.to_param }
      it { is_expected.to eq [manga_1, manga_2, manga_3] }
    end

    context 'kakao_clone' do
      let(:terms) { kakao_clone.to_param }
      it { is_expected.to eq [manga_1, manga_2, manga_3] }
    end

    context 'naver' do
      let(:terms) { naver.to_param }
      it { is_expected.to eq [manga_1, manga_5] }
    end

    context 'kakao, naver' do
      let(:terms) { "#{kakao.to_param},#{naver.to_param}" }
      it { is_expected.to eq [manga_1] }
    end
  end

  context 'negative' do
    context '!kakao' do
      let(:terms) { "!#{kakao.to_param}" }
      it { is_expected.to eq [manga_4, manga_5] }
    end

    context '!naver' do
      let(:terms) { "!#{naver.to_param}" }
      it { is_expected.to eq [manga_2, manga_3, manga_4] }
    end

    context '!kakao,!naver' do
      let(:terms) { "!#{naver.to_param},!#{kakao.to_param}" }
      it { is_expected.to eq [manga_4] }
    end
  end

  context 'both' do
    context 'kakao,!naver' do
      let(:terms) { "#{kakao.to_param},!#{naver.to_param}" }
      it { is_expected.to eq [manga_2, manga_3] }
    end

    context '!kakao,naver' do
      let(:terms) { "!#{kakao.to_param},#{naver.to_param}" }
      it { is_expected.to eq [manga_5] }
    end
  end

  context 'invalid scope' do
    let(:scope) { Anime.all }
    let(:terms) { 'S' }
    it { expect { subject }.to raise_error InvalidParameterError }
  end
end
