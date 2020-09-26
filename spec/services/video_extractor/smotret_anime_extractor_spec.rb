# describe VideoExtractor::SmotretAnimeExtractor do
#   let(:service) { VideoExtractor::SmotretAnimeExtractor.new url }
#
#   describe 'fetch' do
#     subject { service.fetch }
#     let(:embed_url) { 'http://smotretanime.ru/translations/embed/939915' }
#     let(:image_url) { 'https://smotretanime.ru/translations/thumbnail/939915.320x180.jpg' }
#
#     context 'full url' do
#       let(:url) { 'https://smotretanime.ru/catalog/anime-krasavica-voin-seylor-mun-kristall-apostoly-smerti-13889/12-seriya-122880/ozvuchka-939915' }
#
#       its(:hosting) { is_expected.to eq 'smotret_anime' }
#       its(:image_url) { is_expected.to eq image_url }
#       its(:player_url) { is_expected.to eq embed_url }
#     end
#
#     context 'embed url' do
#       let(:url) { embed_url }
#
#       its(:hosting) { is_expected.to eq 'smotret_anime' }
#       its(:image_url) { is_expected.to eq image_url }
#       its(:player_url) { is_expected.to eq embed_url }
#     end
#   end
# end
