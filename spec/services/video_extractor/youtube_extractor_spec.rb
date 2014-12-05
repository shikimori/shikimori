describe VideoExtractor::YoutubeExtractor do
  let(:service) { VideoExtractor::YoutubeExtractor.new url }

  describe '#fetch' do
    subject { service.fetch }

    context 'valid_url' do
      context 'common case' do
        let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc' }

        its(:hosting) { should eq :youtube }
        its(:image_url) { should eq 'http://img.youtube.com/vi/VdwKZ6JDENc/mqdefault.jpg' }
        its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc' }
      end

      context 'youtu.be' do
        let(:url) { 'http://youtu.be/n5qqfOXRRaA?t=3m3s' }

        its(:hosting) { should eq :youtube }
        its(:image_url) { should eq 'http://img.youtube.com/vi/n5qqfOXRRaA/mqdefault.jpg' }
        its(:player_url) { should eq 'http://youtube.com/v/n5qqfOXRRaA?start=3m3s' }
      end

      context 'with time' do
        let(:url) { 'http://www.youtube.com/watch?v=VdwKZ6JDENc#t=123' }

        its(:hosting) { should eq :youtube }
        its(:image_url) { should eq 'http://img.youtube.com/vi/VdwKZ6JDENc/mqdefault.jpg' }
        its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc?start=123' }
      end

      context 'params after' do
        let(:url) { 'http://youtube.com/watch?v=VdwKZ6JDENc&ff=vcxvcx' }
        its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc' }
      end

      context 'params before' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc' }
        its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc' }
        it { should be_present }
      end

      context 'params_surrounded' do
        let(:url) { 'http://youtube.com/watch?sdfdsf=dfdfs&v=VdwKZ6JDENc&ff=vcxvcx#t=123' }
        its(:player_url) { should eq 'http://youtube.com/v/VdwKZ6JDENc?start=123' }
        it { should be_present }
      end
  end

    context 'invalid url' do
      let(:url) { 'http://vk.com/video98023184_165811692zzz' }
      it { should be_nil }
    end
  end
end
