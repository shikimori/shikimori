require 'spec_helper'

describe Video do
  context '#relations' do
    it { should belong_to :anime }
    it { should belong_to :uploader }
  end

  context '#validations' do
    it { should validate_presence_of :anime_id }
    it { should validate_presence_of :uploader_id }
    it { should validate_presence_of :url }
    it { should validate_presence_of :kind }
  end

  context '#hooks' do
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

  context '#validations' do
    describe :existence do
      let(:video) { build :video, :with_existence, url: 'http://www.youtube.com/watch?v=_TEnq7wuHTQ' }
      before do
        #Video.any_instance.unstub :existence
        Video.any_instance.stub :sleep
        Video.any_instance.stub(:open) { raise OpenURI::HTTPError.new('z','x') }
        video.save
      end

      it { video.errors.messages[:url].should eq ['некорректен, нет такого видео на youtube'] }
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

        describe 'bad domain' do
          let(:url) { 'https://yyoutube.com/watch?v=VdwKZ6JDENc' }
          it { video.errors.messages[:url].should eq ['некорректен, должна быть ссылка на youtube'] }
          it { video.persisted?.should be false }
        end

        describe 'no v param' do
          let(:url) { 'https://youtube.com/watch?vv=VdwKZ6JDENc' }
          it { video.persisted?.should be false }
        end
      end
    end
  end

  describe 'deletion of invalid video' do
    let(:video) { build :video, url: 'https://youtube.com/watch?v=VdwKZ6JDENc' }
    before do
      video.save
      video.update_column :url, 'https://yyoutube.com/watch?v=VdwKZ6JDENc'
      video.del
    end

    it { video.state.should eq 'deleted' }
  end

  describe 'image_url' do
    let(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
    it { video.image_url.should eq 'http://img.youtube.com/vi/VdwKZ6JDENc/mqdefault.jpg' }
  end

  describe 'direct_url' do
    let(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
    it { video.direct_url.should eq 'http://youtube.com/v/VdwKZ6JDENc' }
  end

  describe 'key' do
    let(:video) { build :video, url: 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }
    it { video.key.should eq 'VdwKZ6JDENc' }
  end
end
