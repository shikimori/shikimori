json.html render(
  partial: 'user_rates/user_rate',
  locals: { user_rate: @resource.decorate, entry: @resource.target },
  formats: :html
)
