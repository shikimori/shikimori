describe Video, :type => :model do
  context 'relations' do
    it { should belong_to :anime }
    it { should belong_to :uploader }
  end

  context 'validations' do
    it { should validate_presence_of :anime_id }
    it { should validate_presence_of :uploader_id }
    it { should validate_presence_of :url }
    it { should validate_presence_of :kind }
    #it { should validate_presence_of :hosting }
  end

  context 'hooks' do
    describe 'suggest_acception' do
      it :uploaded do
        expect {
          create :video
        }.to change(UserChange.where(action: UserChange::VideoUpload, status: UserChangeStatus::Pending), :count).by 1
      end

      it :confirmed do
        expect {
          create :video, state: 'confirmed'
        }.to change(UserChange.where(action: UserChange::VideoUpload, status: UserChangeStatus::Taken), :count).by 1
      end
    end

    describe 'suggest_deletion' do
      it :confirmed do
        video = create :video, state: 'confirmed'
        expect {
          video.suggest_deletion create(:user)
        }.to change(UserChange.where(action: UserChange::VideoDeletion), :count).by 1
      end

      it :uploaded do
        video = create :video
        expect {
          video.suggest_deletion create(:user)
        }.to_not change(UserChange, :count)
      end
    end
  end

  context 'validations' do
    describe 'normalize' do
      let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc' }
      subject { video }

      context 'valid url' do
        let(:video) { build :video, url: url }
        before { video.save }
        it { should be_persisted }
      end

      context 'invalid url' do
        let(:video) { build :video, url: url }
        before { video.save }

        describe 'bad youtube url' do
          let(:url) { 'https://yyoutube.com/watch?v=VdwKZ6JDENc' }
          it { should_not be_persisted }
          specify { expect(video.errors.messages[:url]).to eq [I18n.t('activerecord.errors.models.videos.attributes.url.incorrect')] }
        end

        describe 'no v param' do
          let(:url) { 'https://youtube.com/watch?vv=VdwKZ6JDENc' }
          it { should_not be_persisted }
        end
      end
    end
  end

  context 'youtube' do
    subject(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

    its(:hosting) { should eq 'youtube' }
    its(:image_url) { should eq 'http://img.youtube.com/vi/VdwKZ6JDENc/mqdefault.jpg' }
    its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc' }

    describe 'url=' do
      let(:clean_url) { 'http://youtube.com/watch?v=VdwKZ6JDENc' }

      context 'valid url' do
        let(:video) { create(:video, url: url) }
        subject { video.url }

        describe 'https' do
          let(:url) { 'https://youtube.com/watch?v=VdwKZ6JDENc' }
          it { should eq clean_url }
        end

        describe 'hash params' do
          let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc#t=123' }
          it { should eq clean_url + '#t=123' }
        end

        describe 'no www' do
          let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
          it { should eq clean_url }
        end
      end
    end
  end

  context 'vkontakte' do
    subject(:video) { build :video, :with_http_request, url: 'http://vk.com/video98023184_165811692' }
    its(:hosting) { should eq 'vk' }

    context 'saved' do
      before { VCR.use_cassette(:vk_video) { video.save! } }

      its(:image_url) { should eq 'http://cs514511.vk.me/u98023184/video/l_81cce630.jpg' }
      its(:player_url) { should eq 'https://vk.com/video_ext.php?oid=98023184&id=165811692&hash=6d9a4c5f93270892&hd=1' }
    end

    describe 'url=' do
      let(:clean_url) { 'http://vk.com/video98023184_165811692' }

      context 'valid url' do
        let(:video) { build :video, url: url }
        subject { video.url }

        describe 'https' do
          let(:url) { 'https://vk.com/video98023184_165811692' }
          it { should eq clean_url }
        end

        describe 'dash' do
          let(:url) { 'http://vk.com/video-98023184_165811692' }
          it { should eq 'http://vk.com/video-98023184_165811692' }
        end
      end
    end
  end
end
