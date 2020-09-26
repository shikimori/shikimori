# describe VideoExtractor::DailymotionExtractor, :vcr do
#   let(:service) { VideoExtractor::DailymotionExtractor.new url }
# 
#   describe '#fetch' do
#     subject { service.fetch }
# 
#     let(:image_url) { '//s1-ssl.dmcdn.net/L8Mws/526x297-zue.jpg' }
#     let(:player_url) { '//www.dailymotion.com/embed/video/x2wv4l8?autoPlay=0' }
# 
#     context 'embed url' do
#       let(:url) { 'http://www.dailymotion.com/embed/video/x2wv4l8' }
# 
#       its(:hosting) { is_expected.to eq 'dailymotion' }
#       its(:image_url) { is_expected.to eq image_url }
#       its(:player_url) { is_expected.to eq player_url }
#     end
# 
#     context 'svf url' do
#       let(:url) { 'http://www.dailymotion.com/swf/video/x2wv4l8' }
# 
#       its(:hosting) { is_expected.to eq 'dailymotion' }
#       its(:image_url) { is_expected.to eq image_url }
#       its(:player_url) { is_expected.to eq player_url }
#     end
# 
#     context 'short url' do
#       let(:url) { 'http://dai.ly/x2wv4l8' }
# 
#       its(:hosting) { is_expected.to eq 'dailymotion' }
#       its(:image_url) { is_expected.to eq image_url }
#       its(:player_url) { is_expected.to eq player_url }
#     end
#   end
# end
