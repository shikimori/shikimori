require 'acts_as_votable/voter'

module ActsAsVotable
  module ShikiVoter
    def abstained? votable, args={}
     find_votes(
        votable_id: votable.id,
        votable_type: votable.class.base_class.name,
        vote_scope: args[:vote_scope],
        vote_flag: nil
      ).size > 0
    end
  end

  module Helpers
    module ShikiVotableWords
      module ClassMethods
        def meaning_of word
          if that_mean_abstain.include? word
            nil
          elsif that_mean_true.include? word
            true
          else
            false
          end
        end

        def that_mean_abstain
          %w[abstain]
        end
      end

      def self.prepended base
        class << base
          prepend ClassMethods
        end
      end
    end
  end
end

ActsAsVotable::Voter.send :prepend, ActsAsVotable::ShikiVoter
ActsAsVotable::Helpers::VotableWords.send :prepend,
  ActsAsVotable::Helpers::ShikiVotableWords
