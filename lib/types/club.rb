module Types
  module Club
    CommentPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:free, :members, :admins)

    ImageUploadPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:members, :admins)

    JoinPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:free, :admin_invite, :owner_invite)

    TopicPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:members, :admins)
  end
end
