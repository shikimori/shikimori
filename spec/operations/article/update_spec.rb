# frozen_string_literal: true

describe Article::Update do
  subject { Article::Update.call article, params }

  let(:article) { create :article, user: user }

  context 'valid params' do
    let(:params) do
      {
        name: 'test article',
        state: state
      }
    end
    let(:state) { 'unpublished' }

    before { subject }

    it do
      expect(article.errors).to be_empty
      expect(article.reload).to have_attributes params
      expect(article.topics).to be_empty
    end

    describe 'publish' do
      let(:state) { 'published' }
      it do
        expect(article.errors).to be_empty
        expect(article.reload).to have_attributes params
        expect(article.topics).to have(1).item
        expect(article.topics.first.locale).to eq article.locale
      end
    end
  end

  context 'invalid params' do
    let(:params) { { name: '' } }
    before { subject }

    it do
      expect(article.errors).to be_present
      expect(article.reload).not_to have_attributes params
    end
  end
end
