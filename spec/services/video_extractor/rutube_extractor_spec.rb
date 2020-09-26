# describe VideoExtractor::RutubeExtractor, :vcr do
#   let(:service) { VideoExtractor::RutubeExtractor.new url }
#
#   describe 'fetch' do
#     subject { service.fetch }
#
#     let(:url) { 'https://rutube.ru/play/embed/10259595' }
#     let(:embed_url) { 'https://rutube.ru/play/embed/8d2ba036c95314a62ce8a0fed801c81d' }
#     let(:image_url) { 'https://pic.rutube.ru/video/53/fb/53fb1fbf7e5e74e5bf7b8474617d3cf4.jpg' }
#
#     its(:hosting) { is_expected.to eq 'rutube' }
#     its(:image_url) { is_expected.to eq image_url }
#     its(:player_url) { is_expected.to eq embed_url }
#   end
# end
