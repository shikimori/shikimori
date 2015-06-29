describe UserDecorator do
  let(:decorator) { user.decorate }

  describe '#last_online' do
    let(:user) { build :user, :user, last_online_at: last_online_at }

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
        it { expect(decorator.last_online).to eq 'онлайн 10 минут назад' }
      end

      context 'long ago' do
        let(:last_online_at) { Time.zone.parse '19-06-2015' }
        it { expect(decorator.last_online).to eq 'онлайн 19 июня 2015' }
      end
    end
  end
end
