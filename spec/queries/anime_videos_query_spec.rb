require 'spec_helper'

describe AnimeVideosQuery do
  let(:query) { AnimeVideosQuery.new params }
  let(:params) { {} }
  let!(:anime_1) { create :anime, name: 'anime_1_test' }
  let!(:anime_2) { create :anime, name: 'anime_2_test' }

  describe :fetch_ids do
    subject { query.all.fetch_ids }

    context :with_not_allowed do
      let!(:anime_video_1) { create :anime_video, anime: anime_1, state: 'broken' }
      let!(:anime_video_2) { create :anime_video, anime: anime_2 }

      describe :all do
        it { should have(1).items }
      end
    end

    context :adult_filter do
      let!(:anime_video_censored) { create :anime_video, anime: create(:anime, censored: true) }
      let!(:anime_video_17) { create :anime_video, anime: create(:anime, rating: 'R - 17+ (violence & profanity)') }

      it { should be_blank }
    end
  end

  context :allowed do
    let!(:anime_video_1) { create :anime_video, anime: anime_1 }
    let!(:anime_video_2) { create :anime_video, anime: anime_2, created_at: DateTime.now.next_day }

    describe :fetch_ids do
      subject { query_fetch.fetch_ids }

      describe :all do
        let(:query_fetch) { query.all }
        it { should have(2).items }
      end

      describe :page do
        let(:query_fetch) { query.page 1 }
        it { should have(1).items }
      end

      describe :order do
        let(:query_fetch) { query.order.all }
        specify { subject.first.anime_id.should eq anime_2.id }
      end

      describe :search do
        let(:params) { { search: '_2_' } }
        let(:query_fetch) { query.search.all }

        it { should have(1).items }
        specify { subject.first.anime_id.should eq anime_2.id }
      end
    end

    describe :fetch_entries do
      subject { query_fetch.fetch_entries }

      describe :all do
        let(:query_fetch) { query.search.all }
        it { should have(2).items }
      end

      describe :page do
        let(:query_fetch) { query.search.page 1 }
        it { should have(1).items }
      end

      describe :order do
        let(:query_fetch) { query.search.order.all }
        specify { subject.first.id.should eq anime_2.id }
        its(:first) { should be_an_instance_of Anime }
      end

      describe :search do
        let(:params) { { search: '_2_' } }
        let(:query_fetch) { query.search.all }

        it { should have(1).items }
        specify { subject.first.id.should eq anime_2.id }
      end
    end
  end
end
