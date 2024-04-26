describe UserDecorator do
  let(:decorator) { user.decorate }

  describe '#last_online' do
    let(:user) do
      build_stubbed :user, :user,
        last_online_at: last_online_at,
        created_at: 10.years.ago
    end

    context 'admin' do
      let(:user) { build :user, :admin }
      it { expect(decorator.last_online).to eq 'всегда на сайте' }
    end

    context 'online' do
      let(:last_online_at) { 2.minutes.ago }
      it { expect(decorator.last_online).to eq 'сейчас на сайте' }
    end

    context 'offnline' do
      context 'not long ago' do
        let(:last_online_at) { 10.minutes.ago }
        it { expect(decorator.last_online).to eq 'в сети: 10 минут назад' }
      end

      context 'long ago' do
        let(:last_online_at) { Time.zone.parse '19-06-2015' }
        it { expect(decorator.last_online).to eq 'в сети: 19 июня 2015' }
      end
    end
  end
end
