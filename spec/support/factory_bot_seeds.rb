require 'factory_girl-seeds'

class FactoryBotSeeds
  PURE_FACTORIES = %i[
    reviews_forum
    animanga_forum
    contests_forum
    clubs_forum
    cosplay_forum
    collections_forum
    offtopic_forum

    offtopic_topic
    site_rules_topic
    description_of_genres_topic
    ideas_and_suggestions_topic
    site_problems_topic
    contests_proposals_topic

    faq_club
  ]
  PLUS_MODELS_TO_RESET = %i[forum topic]
  FACTORIES = %i[
    user
  ] + PURE_FACTORIES

  module SharedContext
    extend RSpec::Core::SharedContext

    # User.roles.keys.each do |role|
    #   let(:"user_#{role}") { seed :"user_#{role}" }
    # end

    FACTORIES.each do |model|
      let(model) { seed model }
    end
  end

  def self.generate!
    create :user, id: 500_000, email: 'seed_1@gmail.com'

    # User.roles.keys.each_with_index do |role, index|
    #   create :"user_#{role}", id: 1000 + index
    # end

    PURE_FACTORIES.each { |factory| create factory }

    reset_pk_sequence!
  end

  def self.reset_pk_sequence!
    (PURE_FACTORIES + PLUS_MODELS_TO_RESET).each do |model|
      ActiveRecord::Base.connection.reset_pk_sequence! model.to_s.pluralize
    end
  end

  private_class_method

  def self.create factory, params = {}
    FactoryGirl::SeedGenerator.create factory, params
  end
end

RSpec.configure do |config|
  config.include FactoryBotSeeds::SharedContext
end
