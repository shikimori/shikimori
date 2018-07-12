describe PgCache do
  include_context :timecop

  let(:find_entry) { PgCacheData.find_by key: key }

  let(:key) { 'key' }
  let(:value) { [{ a: :b }] }
  let(:expires_at) { 1.hour }

  describe '.write' do
    subject { described_class.write key, value, expires_in: expires_at }

    context 'no key' do
      it do
        expect { subject }.to change(PgCacheData, :count).by 1

        is_expected.to eq value

        expect(find_entry.value).to eq YAML.dump(value)
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end

      context 'no expires_at' do
        let(:expires_at) { nil }

        it do
          expect { subject }.to change(PgCacheData, :count).by 1

          is_expected.to eq value

          expect(find_entry.value).to eq YAML.dump(value)
          expect(find_entry.expires_at).to be_nil
        end
      end
    end

    context 'has key' do
      let!(:entry) { create :pg_cache_data, key: key }

      it do
        expect { subject }.to_not change PgCacheData, :count

        is_expected.to eq value

        expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound

        expect(find_entry.value).to eq YAML.dump(value)
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end
    end

    context 'array key' do
      let(:key) { ['key1', 'key2'] }
      let(:find_entry) { PgCacheData.find_by key: key.join('_') }

      it do
        expect { subject }.to change(PgCacheData, :count).by 1

        is_expected.to eq value

        expect(find_entry.value).to eq YAML.dump(value)
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end
    end
  end

  describe '.read' do
    subject { described_class.read key }

    context 'has key' do
      context 'not expred' do
        let!(:entry) { create :pg_cache_data, key: key, expires_at: 1.minute.from_now }
        it { is_expected.to eq YAML.load(entry.value) } # rubocop:disable YAMLLoad
      end

      context 'expired' do
        let!(:entry) { create :pg_cache_data, key: key, expires_at: 1.minute.ago }
        it { is_expected.to be_nil }
      end
    end

    context 'no key' do
      it { is_expected.to be_nil }
    end
  end

  describe '.fetch' do
    subject { described_class.fetch(key, expires_in: expires_at) { value } }

    context 'has key' do
      context 'not expred' do
        let!(:entry) { create :pg_cache_data, key: key, expires_at: 1.minute.from_now }
        it do
          expect { subject }.to_not change PgCacheData, :count

          is_expected.to eq YAML.load(entry.value) # rubocop:disable YAMLLoad
          is_expected.to_not eq value
        end
      end

      context 'expired' do
        let!(:entry) { create :pg_cache_data, key: key, expires_at: 1.minute.ago }
        it do
          expect { subject }.to_not change PgCacheData, :count

          is_expected.to eq value

          expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound

          expect(find_entry.value).to eq YAML.dump(value)
          expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
        end
      end
    end

    context 'no key' do
      let(:entry) { PgCacheData.find_by key: key }

      it do
        expect { subject }.to change(PgCacheData, :count).by 1

        is_expected.to eq value

        expect(find_entry.value).to eq YAML.dump(value)
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end
    end
  end

  describe '.delete' do
    subject { described_class.delete key }

    context 'has key' do
      let!(:entry) { create :pg_cache_data, key: key }
      it do
        expect { subject }.to change(PgCacheData, :count).by(-1)
        expect { entry.reload }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context 'no key' do
      it { expect { subject }.to_not change PgCacheData, :count }
    end
  end
end
