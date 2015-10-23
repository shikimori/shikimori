describe Topics::View do
  include_context :view_object_warden_stub
  let(:view) { Topics::View.new topic }

  let(:review_comment) { build_stubbed :review_comment, linked: review }
  let(:review) { build_stubbed :review, target: anime }
  let(:anime) { build_stubbed :anime, name: 'Naruto', russian: 'Наруто' }

  describe '#topic_title' do
    context 'review' do
      let(:topic) { review_comment }
      it { expect(view.topic_title).to eq "Обзор аниме #{anime.russian}" }
    end
  end
end
