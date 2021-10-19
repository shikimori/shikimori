shared_examples_for :successful_resource_change do |type|
  it do
    expect(resource).to be_persisted
    expect(resource).to have_attributes(params)
    expect(response).to have_http_status :success

    case type
      when :api then expect(json).to_not include :content
      when :frontend then expect(json).to include :content
      else
        raise ArgumentError, "unknown type #{type} (allowed :api or :frontend)"
    end

    expect(response.content_type).to eq 'application/json'
  end
end
