module Types
  module Club
    ImageUploadPolicy = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:members, :admins)
  end
end
