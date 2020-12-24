# NOTE: disabled because can find out how to get these routes properly in specs
# describe TranslationsController do
#   let!(:translations_club) { create :club, id: 2 }
#
#   describe '#description' do
#     context 'anime' do
#       let!(:miyazaki) { create :person, id: 1870 }
#       before { get :description, params: { anime: true } }
#       it { expect(response).to have_http_status :success }
#     end
#
#     context 'manga' do
#       before { get :description, params: { manga: true } }
#       it { expect(response).to have_http_status :success }
#     end
#   end
#
#   describe '#name' do
#     context 'anime' do
#       before { get :name, params: { anime: true } }
#       it { expect(response).to have_http_status :success }
#     end
#
#     context 'manga' do
#       before { get :name, params: { manga: true } }
#       it { expect(response).to have_http_status :success }
#     end
#   end
# end
