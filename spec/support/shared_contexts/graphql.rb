shared_context :graphql do
  let(:context) { {} }
  let(:base_context) { {} }
  let(:variables) { {} }
  let(:result) do
    ShikimoriSchema.execute(
      query_string,
      context: base_context.merge(context),
      variables:
    )
  end
  subject { result['data'] }
end
