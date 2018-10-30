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
        expect(find_entry.blob).to be_nil
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end

      context 'no expires_at' do
        let(:expires_at) { nil }

        it do
          expect { subject }.to change(PgCacheData, :count).by 1

          is_expected.to eq value

          expect(find_entry.value).to eq YAML.dump(value)
          expect(find_entry.blob).to be_nil
          expect(find_entry.expires_at).to be_nil
        end
      end
    end

    context 'has key' do
      let!(:entry) { create :pg_cache_data, key: key }

      it do
        expect { subject }.to_not change PgCacheData, :count

        is_expected.to eq value

        expect(entry.reload).to eq find_entry

        expect(find_entry.value).to eq YAML.dump(value)
        expect(find_entry.blob).to be_nil
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
        expect(find_entry.blob).to be_nil
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end
    end

    context 'MessagePack serializer' do
      subject do
        described_class.write key, value,
          expires_in: expires_at,
          serializer: MessagePack
      end

      let(:value) { [{ 'a' => 'b' }] }
      let(:find_entry) { PgCacheData.find_by key: key }

      it do
        expect { subject }.to change(PgCacheData, :count).by 1

        is_expected.to eq value

        expect(find_entry.value).to be_nil
        expect(find_entry.blob).to eq MessagePack.dump(value)
        expect(find_entry.expires_at).to be_within(0.1).of expires_at.from_now
      end
    end
  end

  describe '.read' do
    subject { described_class.read key }

    context 'has key' do
      context 'not expred' do
        let!(:entry) do
          create :pg_cache_data,
            key: key,
            expires_at: 1.minute.from_now,
            value: YAML.dump(value)
        end

        it do
          is_expected.to eq value
          is_expected.to eq YAML.load(entry.value) # rubocop:disable YAMLLoad
        end
      end

      context 'expired' do
        let!(:entry) do
          create :pg_cache_data,
            key: key,
            expires_at: 1.minute.ago
        end
        it { is_expected.to be_nil }
      end
    end

    context 'no key' do
      it { is_expected.to be_nil }
    end

    context 'MessagePack serializer' do
      let!(:entry) do
        create :pg_cache_data,
          key: key,
          expires_at: 1.minute.from_now,
          blob: MessagePack.dump(value)
      end
      let(:value) { [{ 'a' => 'b' }] }
      subject { described_class.read key, serializer: MessagePack }

      let(:find_entry) { PgCacheData.find_by key: key }

      it do
        is_expected.to eq value
        # is_expected.to eq MessagePack.load(entry.value)
      end
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

          expect(entry.reload).to eq find_entry

          expect(find_entry.value).to eq YAML.dump(value)
          expect(find_entry.blob).to be_nil
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
        expect(find_entry.blob).to be_nil
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
