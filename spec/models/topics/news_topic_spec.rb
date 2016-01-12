describe Topics::NewsTopic do
  describe 'enumerize' do
    it { is_expected.to enumerize(:action).in :anons, :ongoing, :released, :episode }
  end
end
