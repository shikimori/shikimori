describe Articles::Query do
  let(:query) { Articles::Query.fetch(:ru) }

  include_context :timecop

  let!(:article_1) { create :article, :published, id: 1 }
  let!(:article_2) { create :article, :published, id: 2 }
  let!(:article_3) { create :article, :published, id: 3 }
  let!(:article_4) { create :article, :unpublished, id: 4 }
  let!(:article_en_1) { create :article, :published, id: 5 }
  let!(:article_en_2) { create :article, :unpublished, id: 6 }

  describe '.fetch' do
    subject { query }
    it { is_expected.to eq [article_3, article_2, article_1] }

    describe '#search' do
      subject { query.search phrase, 'ru' }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::Article).to receive(:call).with(
            phrase: phrase,
            limit: Articles::Query::SEARCH_LIMIT
          ).and_return(
            article_3.id => 987,
            article_2.id => 654,
            article_en_1.id => 321
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [article_3, article_2]
          expect(Elasticsearch::Query::Article).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::Article).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [article_3, article_2, article_1]
          expect(Elasticsearch::Query::Article).to_not have_received :call
        end
      end
    end
  end
end
