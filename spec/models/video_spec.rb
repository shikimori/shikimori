require 'spec_helper'

describe Video do
  context :relations do
    it { should belong_to :anime }
    it { should belong_to :uploader }
  end

  context :validations do
    it { should validate_presence_of :anime_id }
    it { should validate_presence_of :uploader_id }
    it { should validate_presence_of :url }
    it { should validate_presence_of :kind }
  end

  context :hooks do
    describe :suggest_acception do
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

    describe :suggest_deletion do
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

  context :validations do
    describe :existence do
      let(:video) { build :video, :with_http_request, url: 'http://www.youtube.com/watch?v=_TEnq7wuHTQ' }
      before { VCR.use_cassette(:vk_video) { video.save } }

      it { video.errors.messages[:url].should eq [I18n.t('activerecord.errors.models.videos.attributes.url.youtube_not_exist')] }
      it { video.persisted?.should be false }
    end

    describe :normalize do
      let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc' }

      context 'valid url' do
        let(:video) { build :video, url: url }
        before { video.save }
        it { video.persisted?.should be true }
      end

      context 'invalid url' do
        let(:video) { build :video, url: url }
        before { video.save }

        describe 'bad youtube url' do
          let(:url) { 'https://yyoutube.com/watch?v=VdwKZ6JDENc' }
          it { video.persisted?.should be false }
          it { video.errors.messages[:url].should eq [I18n.t('activerecord.errors.models.videos.attributes.url.incorrect')] }
        end

        describe 'no v param' do
          let(:url) { 'https://youtube.com/watch?vv=VdwKZ6JDENc' }
          it { video.persisted?.should be false }
        end
      end
    end
  end

  #describe 'deletion of invalid video' do
    #let(:video) { build :video, url: 'https://youtube.com/watch?v=VdwKZ6JDENc' }
    #before do
      #video.save
      #video.update_column :url, 'https://yyoutube.com/watch?v=VdwKZ6JDENc'
      #video.del
    #end

    #it { video.state.should eq 'deleted' }
  #end

  context :youtube do
    subject(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

    its(:youtube?) { should be_true }
    its(:vk?) { should be_false }
    its(:hosting) { should eq :youtube }
    its(:image_url) { should eq 'http://img.youtube.com/vi/VdwKZ6JDENc/mqdefault.jpg' }
    its(:direct_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc' }
    its(:key) { should eq 'VdwKZ6JDENc' }

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
          let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc#zzzz?Afdsfsds' }
          it { should eq clean_url }
        end

        describe 'no www' do
          let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
          it { should eq clean_url }
        end

        describe 'params after ' do
          let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&ff=vcxvcx' }
          it { should eq clean_url }
        end

        describe 'params before' do
          let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc' }
          it { should eq clean_url }
        end

        describe 'params surrounded' do
          let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc&ff=vcxvcx' }
          it { should eq clean_url }
        end
      end
    end
  end

  context :vkontakte do
    subject(:video) { build :video, :with_http_request, url: 'http://vk.com/video98023184_165811692' }
    its(:youtube?) { should be_false }
    its(:vk?) { should be_true }
    its(:hosting) { should eq :vk }

    context :saved do
      before { VCR.use_cassette(:vk_video) { video.save! } }
      its(:image_url) { should eq 'http://cs514511.vk.me/u98023184/video/l_81cce630.jpg' }
      its(:direct_url) { should eq 'https://vk.com/video_ext.php?oid=98023184&id=165811692&hash=6d9a4c5f93270892&hd=1' }
    end

    describe :details do
      let(:details) { 'some vk video details' }

      context :fetched do
        before { video.should_receive(:fetch_vk_details).and_return 'some vk video details' }
        its(:details) { should eq 'some vk video details' }
      end

      context :not_fetched do
        before { video[:details] = 'another vk video details' }
        before { video.should_not_receive :fetch_vk_details }
        its(:details) { should eq 'another vk video details' }
      end
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
