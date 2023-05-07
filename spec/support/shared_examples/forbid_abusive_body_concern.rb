shared_examples :forbid_abusive_body_concern do |type|
  describe 'forbid_abusive_body concern' do
    context '#forbid_abusive_content' do
      let(:model) { build type, body: 'хуй ' + ('a' * 9999) }
      before { model.save }

      it do
        expect(model.errors[:body]).to eq [
          I18n.t('activerecord.errors.models.review.attributes.body.abusive_content')
        ]
      end
    end
  end
end
