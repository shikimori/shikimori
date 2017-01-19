module Types
  module Club
    ImageUploadPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*%i(members admins))
  end
end
