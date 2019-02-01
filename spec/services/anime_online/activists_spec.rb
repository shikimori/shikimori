# describe AnimeOnline::Activists do
#   before { stub_const 'AnimeOnline::Activists::ENOUGH_TO_TRUST_RUTUBE', 2 }
#   before { AnimeOnline::Activists.reset }
#   let(:user) { create :user, id: 9999 }

#   describe '.rutube_responsible' do
#     subject { AnimeOnline::Activists.rutube_responsible }

#     context 'empty' do
#       it { is_expected.to eq [] }
#     end

#     context 'not enough' do
#       let(:anime_video) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm1'
#       end
#       let!(:report) do
#         create :anime_video_report,
#           anime_video: anime_video,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end

#       it { is_expected.to eq [] }
#     end

#     context 'enough but other hosting' do
#       let(:anime_video_1) do
#         create :anime_video,
#           url: attributes_for(:anime_video)[:url]
#       end
#       let(:anime_video_2) do
#         create :anime_video,
#           url: attributes_for(:anime_video)[:url] + 'a'
#       end
#       let!(:report_1) do
#         create :anime_video_report,
#           anime_video: anime_video_1,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end
#       let!(:report_2) do
#         create :anime_video_report,
#           anime_video: anime_video_2,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end

#       it { is_expected.to eq [] }
#     end

#     context 'enough' do
#       let(:anime_video_1) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm1'
#       end
#       let(:anime_video_2) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm2'
#       end
#       let!(:report_1) do
#         create :anime_video_report,
#           anime_video: anime_video_1,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end
#       let!(:report_2) do
#         create :anime_video_report,
#           anime_video: anime_video_2,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end

#       it { is_expected.to eq [user.id] }
#     end

#     context 'enough but has rejected' do
#       let(:anime_video_1) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm1'
#       end
#       let(:anime_video_2) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm2'
#       end
#       let(:anime_video_3) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm3'
#       end
#       let!(:report_1) do
#         create :anime_video_report,
#           anime_video: anime_video_1,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end
#       let!(:report_2) do
#         create :anime_video_report,
#           anime_video: anime_video_2,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end
#       let!(:report_3) do
#         create :anime_video_report,
#           anime_video: anime_video_3,
#           state: 'rejected',
#           kind: 'broken',
#           user: user
#       end

#       it { is_expected.to eq [] }
#     end
#   end

#   describe '.can_trust?' do
#     subject { AnimeOnline::Activists.can_trust?(user.id, 'rutube.ru') }

#     context 'false' do
#       it { is_expected.to eq false }
#     end

#     context 'true' do
#       let(:anime_video_1) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm1'
#       end
#       let(:anime_video_2) do
#         create :anime_video,
#           url: 'http://rutube.ru/qazxswedcvfrtgbnhyujm2'
#       end
#       let!(:report_1) do
#         create :anime_video_report,
#           anime_video: anime_video_1,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end
#       let!(:report_2) do
#         create :anime_video_report,
#           anime_video: anime_video_2,
#           state: 'accepted',
#           kind: 'broken',
#           user: user
#       end

#       it { is_expected.to eq true }
#     end
#   end
# end
