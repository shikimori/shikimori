describe Animes::SortField do
  let(:query) { Animes::SortField.new default, view_context }

  let(:default) { :zz }
  let(:view_context) do
    double(
      ru_content?: ru_content,
      user_signed_id?: user.present?,
      current_user: user,
      params: { order: order }
    )
  end

  let(:user) { create :user, language: language }
  let(:language) { :russian }
  let(:ru_content) { true }

  describe '#field' do
    context 'order not set' do
      let(:order) { nil }
      it { expect(query.field).to eq default }
    end

    context 'some field' do
      let(:order) { 'zzz' }
      it { expect(query.field).to eq order }
    end

    context 'name or russian order' do
      let(:order) { 'name' }

      context 'english domain' do
        let(:ru_content) { false }

        context 'guest' do
          let(:user) { nil }

          context 'name' do
            it { expect(query.field).to eq 'name' }
          end

          context 'russian' do
            it { expect(query.field).to eq 'name' }
          end
        end

        context 'authenticated' do
          context 'russian language' do
            let(:language) { :russian }

            context 'russian names' do
              before { user.preferences.russian_names = true }
              it { expect(query.field).to eq 'name' }
            end

            context 'english names' do
              before { user.preferences.russian_names = false }
              it { expect(query.field).to eq 'name' }
            end
          end
        end
      end

      context 'russian domain' do
        let(:ru_content) { true }

        context 'guest' do
          let(:user) { nil }
          it { expect(query.field).to eq 'russian' }
        end

        context 'authenticated' do
          context 'russian language' do
            let(:language) { :russian }

            context 'russian names' do
              before { user.preferences.russian_names = true }
              it { expect(query.field).to eq 'russian' }
            end

            context 'english names' do
              before { user.preferences.russian_names = false }
              it { expect(query.field).to eq 'name' }
            end
          end

          context 'english language' do
            let(:language) { :english }

            context 'russian names' do
              before { user.preferences.russian_names = true }
              it { expect(query.field).to eq 'name' }
            end

            context 'english names' do
              before { user.preferences.russian_names = false }
              it { expect(query.field).to eq 'name' }
            end
          end
        end
      end
    end
  end
end
