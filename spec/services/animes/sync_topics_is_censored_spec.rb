describe Animes::SyncTopicsIsCensored do
  %i[anime manga].each do |kind|
    context kind do
      let(:entry) { create kind, is_censored: is_censored }
      let(:is_censored) { false }
      let!(:linked_topic) do
        create :"#{kind}_topic", linked: entry, is_censored: !is_censored
      end
      let(:critique) { create :critique, target: entry }
      let!(:critique_topic) do
        create :critique_topic, linked: critique, is_censored: !is_censored
      end
      let(:review) { create :review, kind => entry }
      let!(:review_topic) do
        create :review_topic, linked: review, is_censored: !is_censored
      end

      subject! { Animes::SyncTopicsIsCensored.call entry }

      it do
        expect(linked_topic.reload.is_censored).to eq is_censored
        expect(critique_topic.reload.is_censored).to eq is_censored
        expect(review_topic.reload.is_censored).to eq is_censored
      end
    end
  end
end
