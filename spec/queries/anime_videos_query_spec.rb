require 'spec_helper'

describe AnimeVideosQuery do
  let(:query) { AnimeVideosQuery.new params }
  let!(:anime) { create :anime, name: 'find_test' }
  let!(:anime_video) { create :anime_video, anime: anime }

  describe :fetch do
    subject { query.fetch }

    context :with_search do
      let(:params) { { search: search } }

      context :find_by_name do
        let(:search) { 'ind_te' }
        it { should eq [anime] }
      end

      context :no_like_name do
        let(:search) { 'no_videos' }
        it { should be_empty }
      end
    end

    context :without_search do
      let(:params) { {} }

      context :find do
        it { should eq [anime] }
      end
    end
  end

  describe :fetch_ids do
    subject { query.fetch_ids }

    context :with_search do
      let(:params) { { search: search } }

      context :find_by_name do
        let(:search) { 'ind_te' }
        it { should have(1).items }
      end

      context :no_like_name do
        let(:search) { 'no_videos' }
        it { should be_empty }
      end
    end

    context :without_search do
      let(:params) { {} }

      context :find do
        it { should have(1).items }
      end
    end
  end
end
