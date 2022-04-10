describe Video do
  describe 'relations' do
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to :uploader }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to validate_presence_of :kind }
    # it { is_expected.to validate_presence_of :hosting }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:hosting).in(*Types::Video::Hosting.values) }
    it { is_expected.to enumerize(:kind).in(*Types::Video::Kind.values) }
  end

  describe 'aasm' do
    subject { build :video, state }

    context 'uploaded' do
      let(:state) { :uploaded }

      it { is_expected.to have_state state }
      it { is_expected.to allow_transition_to :confirmed }
      it { is_expected.to transition_from(state).to(:confirmed).on_event(:confirm) }
      it { is_expected.to allow_transition_to :deleted }
      it { is_expected.to transition_from(state).to(:deleted).on_event(:del) }
    end

    context 'confirmed' do
      let(:state) { :confirmed }

      it { is_expected.to_not allow_transition_to :uploaded }
      it { is_expected.to allow_transition_to :deleted }
      it { is_expected.to transition_from(state).to(:deleted).on_event(:del) }
    end

    context 'deleted' do
      let(:state) { :deleted }

      it { is_expected.to have_state state }
      it { is_expected.to_not allow_transition_to :uploaded }
      it { is_expected.to allow_transition_to :confirmed }
      it { is_expected.to transition_from(state).to(:confirmed).on_event(:confirm) }
    end
  end

  describe 'validations' do
    describe 'normalize' do
      let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc' }
      subject { video }

      context 'valid url' do
        let(:video) { build :video, url: url }
        before { video.save }
        it { is_expected.to be_persisted }
      end

      context 'invalid url' do
        let(:video) { build :video, url: url }
        before { video.save }

        describe 'bad youtube url' do
          let(:url) { 'https://yyoutube.com/watch?v=VdwKZ6JDENc' }
          it { is_expected.to_not be_persisted }
          specify { expect(video.errors.messages[:url]).to eq [I18n.t('activerecord.errors.models.videos.attributes.url.incorrect')] }
        end

        describe 'no v param' do
          let(:url) { 'https://youtube.com/watch?vv=VdwKZ6JDENc' }
          it { is_expected.to_not be_persisted }
        end
      end
    end
  end

  context 'youtube' do
    subject(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

    its(:hosting) { is_expected.to eq 'youtube' }
    its(:image_url) { is_expected.to eq '//img.youtube.com/vi/VdwKZ6JDENc/hqdefault.jpg' }
    its(:player_url) { is_expected.to eq '//youtube.com/embed/VdwKZ6JDENc' }

    describe 'url=' do
      let(:clean_url) { 'https://youtube.com/watch?v=VdwKZ6JDENc' }

      context 'valid url' do
        let(:video) { create(:video, url: url) }
        subject { video.url }

        describe 'https' do
          let(:url) { 'https://youtube.com/watch?v=VdwKZ6JDENc' }
          it { is_expected.to eq clean_url }
        end

        describe 'hash params' do
          let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc#t=123' }
          it { is_expected.to eq clean_url + '#t=123' }
        end

        describe 'no www' do
          let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
          it { is_expected.to eq clean_url }
        end
      end
    end
  end

  context 'vkontakte', :vcr do
    subject(:video) { build :video, url: 'http://vk.com/video98023184_165811692' }
    its(:hosting) { is_expected.to eq 'vk' }

    context 'saved' do
      before { video.save! }

      its(:image_url) { is_expected.to eq '//pp.userapi.com/c514511/u98023184/video/l_81cce630.jpg' }
      its(:player_url) { is_expected.to eq '//vk.com/video_ext.php?oid=98023184&id=165811692&hash=6d9a4c5f93270892' }
    end

    describe 'url=' do
      let(:clean_url) { 'https://vk.com/video98023184_165811692' }

      context 'valid url' do
        let(:video) { build :video, url: url }
        subject { video.url }

        describe 'https' do
          let(:url) { 'https://vk.com/video98023184_165811692' }
          it { is_expected.to eq clean_url }
        end

        describe 'dash' do
          let(:url) { 'http://vk.com/video-98023184_165811692' }
          it { is_expected.to eq 'https://vk.com/video-98023184_165811692' }
        end
      end
    end
  end
end
