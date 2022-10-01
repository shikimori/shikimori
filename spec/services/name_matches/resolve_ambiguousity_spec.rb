describe NameMatches::ResolveAmbiguousity do
  let(:service) { described_class.new animes, options }
  let(:anime_1) { build_stubbed :anime, name: ['test'] }
  let(:anime_2) { build_stubbed :anime, name: ['test'] }
  let(:animes) { [anime_1, anime_2] }

  describe '#resolve' do
    subject { service.call }

    describe 'no options' do
      let(:options) { {} }
      it { should eq animes }
    end

    describe 'year' do
      let(:options) { { year: 2000 } }

      describe 'no exact matches' do
        it { should eq animes }
      end

      describe 'exact match by year' do
        let(:anime_1) { build_stubbed :anime, name: ['test'], aired_on: '2000-01-01' }
        it { should eq [anime_1] }
      end
    end

    describe 'status' do
      let(:options) { { status: :ongoing } }

      describe 'no_exact_matches' do
        it { should eq animes }
      end

      describe 'exact match by status' do
        let(:anime_1) { build_stubbed :anime, status: :ongoing }
        it { should eq [anime_1] }
      end
    end

    describe 'episodes' do
      let(:options) { { episodes: 21 } }

      describe 'no exact matches' do
        it { should eq animes }
      end

      describe 'exact match by year' do
        let(:anime_1) { build_stubbed :anime, name: ['test'], episodes: 20 }
        it { should eq [anime_1] }
      end
    end

    describe 'kind' do
      let(:options) { { kind: :ova } }

      describe 'no_exact_matches' do
        it { should eq animes }
      end

      describe 'exact match by status' do
        let(:anime_1) { build_stubbed :anime, kind: :ova }
        it { should eq [anime_1] }
      end
    end
  end
end
