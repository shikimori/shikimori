describe SimilarUsersService do
  let(:service) { SimilarUsersService.new user, Anime, 50 }

  let(:user_1) { create :user }
  let(:user_2) { create :user }
  let(:user_3) { create :user }

  before do
    allow(service).to receive(:similarities).and_return [
      [user_1.id, 0.2],
      [user_2.id, 0.7],
      [user_3.id, 0.4]
    ]
  end

  it { expect(service.fetch).to eq [user_2.id, user_3.id, user_1.id] }
end
