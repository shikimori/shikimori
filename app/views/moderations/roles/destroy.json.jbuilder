json.content render(
  partial: 'moderations/roles/user',
  object: @target_user.decorate,
  locals: {
    with_action: true,
    role: @role
  },
  formats: :html
)
