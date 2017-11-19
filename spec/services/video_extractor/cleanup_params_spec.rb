describe VideoExtractor::CleanupParams do
  subject { described_class.call url, allowed_params }
  let(:url) { 'http://vk.com/video_ext.php?oid=36842689&qwe=vbn&id=163317311&hash=e446fa5312813ebc&zxc=1#qwe' }
  let(:allowed_params) { %w[oid id hash] }

  it { is_expected.to eq 'http://vk.com/video_ext.php?oid=36842689&id=163317311&hash=e446fa5312813ebc' }
end
