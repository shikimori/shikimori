describe PgCache do
  describe 'validations' do
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :value }
  end

  describe 'class methods' do
    describe '.write' do
      include_context :timecop

      subject { described_class.write key, value, expires_in: expires_at }

      let(:key) { 'key' }
      let(:value) { { a: :b } }
      let(:expires_at) { 1.hour }

      context 'no key' do
        let(:entry) { PgCache.find_by key: key }

        it do
          expect { subject }.to change(PgCache, :count).by 1
          is_expected.to eq value
          expect(entry.value).to eq value
          expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
        end

        context 'no expires_at' do
          let(:expires_at) { nil }

          it do
            expect { subject }.to change(PgCache, :count).by 1
            is_expected.to eq value
            expect(entry.value).to eq value
            expect(entry.expires_at).to be_nil
          end
        end
      end

      context 'has key' do
        let!(:entry) { create :pg_cache, key: key }

        it do
          expect { subject }.to_not change PgCache, :count
          is_expected.to eq value
          expect(entry.reload.value).to eq value
          expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
        end
      end
    end

    describe '.read' do
      subject { described_class.read key }
      let(:key) { 'test' }

      context 'has key' do
        context 'not expred' do
          let!(:entry) { create :pg_cache, key: key, expires_at: 1.minute.from_now }
          it { is_expected.to eq entry.value }
        end

        context 'expired' do
          let!(:entry) { create :pg_cache, key: key, expires_at: 1.minute.ago }
          it { is_expected.to be_nil }
        end
      end

      context 'no key' do
        it { is_expected.to be_nil }
      end
    end

    describe '.fetch' do
      include_context :timecop

      subject { described_class.fetch(key, expires_in: expires_at) { value } }

      let(:key) { 'test' }
      let(:value) { { a: :b } }
      let(:expires_at) { 1.hour }

      context 'has key' do
        context 'not expred' do
          let!(:entry) { create :pg_cache, key: key, expires_at: 1.minute.from_now }
          it do
            expect { subject }.to_not change PgCache, :count
            is_expected.to eq entry.value
            is_expected.to_not eq value
          end
        end

        context 'expired' do
          let!(:entry) { create :pg_cache, key: key, expires_at: 1.minute.ago }
          it do
            expect { subject }.to_not change PgCache, :count
            is_expected.to eq value
            expect(entry.reload.value).to eq value
            expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
          end
        end
      end

      context 'no key' do
        let(:entry) { PgCache.find_by key: key }

        it do
          expect { subject }.to change(PgCache, :count).by 1
          is_expected.to eq value
          expect(entry.value).to eq value
          expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
        end
      end
    end

    describe '.delete' do
      subject { described_class.delete key }
      let(:key) { 'test' }

      context 'has key' do
        let!(:entry) { create :pg_cache, key: key }
        it do
          expect { subject }.to change(PgCache, :count).by(-1)
          expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
        end
      end

      context 'no key' do
        it { expect { subject }.to_not change PgCache, :count }
      end
    end
  end
end
