# describe VideoExtractor::SovetRomanticaExtractor, :vcr do
#   let(:service) { VideoExtractor::SovetRomanticaExtractor.new url }
#
#   describe 'fetch' do
#     subject! { service.fetch }
#     let(:embed_url) { 'https://sovetromantica.com/embed/episode_116_12-subtitles' }
#     let(:player_url) { '//sovetromantica.com/embed/episode_116_12-subtitles' }
#
#     context 'full url' do
#       let(:url) { 'https://sovetromantica.com/anime/116-watashi-ga-motete-dousunda/episode_12-subtitles' }
#       let(:image_url) { '//chitoge.sovetromantica.com/anime/116_91-days/images/episode_12_sub.jpg?1476629907' }
#
#       it do
#         expect(subject.hosting).to eq 'sovet_romantica'
#         expect(subject.image_url).to eq image_url
#         expect(subject.player_url).to eq player_url
#       end
#     end
#
#     context 'embed url' do
#       let(:url) { embed_url }
#       let(:image_url) { '//chitoge.sovetromantica.com/anime/116_91-days/images/episode_12_sub.jpg?1476637107' }
#
#       it do
#         expect(subject.hosting).to eq 'sovet_romantica'
#         expect(subject.image_url).to eq image_url
#         expect(subject.player_url).to eq player_url
#       end
#     end
#   end
# end
