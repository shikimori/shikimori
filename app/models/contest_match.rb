class ContestMatch < ActiveRecord::Base
  Undefined = 'undefined variant'

  belongs_to :round, class_name: ContestRound.name, touch: true
  belongs_to :left, polymorphic: true
  belongs_to :right, polymorphic: true

  has_many :contest_user_votes
  has_many :votes, class_name: ContestUserVote.name, dependent: :destroy

  scope :with_user_vote, lambda { |user, ip|
    if user
      joins("left join #{ContestUserVote.table_name} cuv on cuv.contest_match_id=`#{table_name}`.`id` and (cuv.id is null or cuv.user_id=#{sanitize user.id} or cuv.ip=#{sanitize ip})")
        .select("`#{table_name}`.*, cuv.item_id as voted_id")
    else
      select("`#{table_name}`.*, null as voted_id")
    end
  }

  scope :with_votes, -> {
    joins("left join #{ContestUserVote.table_name} cuv on cuv.contest_match_id=`#{table_name}`.`id`")
      .group("`#{table_name}`.id")
      .select("`#{table_name}`.*,
               sum(if(cuv.item_id=0, 1, 0)) as refrained_votes,
               sum(if(cuv.item_id=left_id, 1, 0)) as left_votes,
               sum(if(cuv.item_id=right_id, 1, 0)) as right_votes")
  }

  state_machine :state, initial: :created do
    state :created do
      def can_vote?
        false
      end
    end

    state :started do
      def can_vote?
        true
      end

      # голосование за конкретный вариант
      def vote_for(variant, user, ip)
        votes.where(user_id: user.id).delete_all
        votes.create! user: user, contest_match_id: id, item_id: variant.to_s == 'none' ? 0 : send("#{variant}_id"), ip: ip
      end

      # обновление статуса пользоваетля в зависимости от возможности голосовать далее
      def update_user(user, ip)
        if round.matches.with_user_vote(user, ip).select(&:started?).all?(&:voted?)
          user.update_attribute round.contest.user_vote_key, false
        end
      end
    end

    state :finished do
      def can_vote?
        false
      end

      # победитель
      def winner
        if winner_id == left_id
          left
        else
          right
        end
      end

      # проигравший
      def loser
        if winner_id == left_id
          right
        else
          left
        end
      end
    end

    event :start do
      transition created: :started, if: lambda {|match| match.started_on <= Date.today }
    end
    event :finish do
      transition started: :finished, if: lambda {|match| match.finished_on < Date.today }
    end

    after_transition created: :started do |match, transition|
      User.update_all match.round.contest.user_vote_key => true

      if match.right.nil?
        match.right = nil
        match.save!

      elsif match.left.nil? && match.right.present?
        match.left = match.right
        match.right = nil
        match.save!
      end
    end

    after_transition started: :finished do |match, transition|
      winner_id = if match.right_id.nil?
        match.left_id

      elsif match.left_votes > match.right_votes
        match.left_id

      elsif match.right_votes > match.left_votes
        match.right_id

      elsif match.left.respond_to?(:score) && match.right.respond_to?(:score)
        if match.right.score > match.left.score
          match.right_id
        else
          match.left_id
        end

      else
        match.left_id
      end

      match.update_attribute :winner_id, winner_id
    end
  end

  # за какой вариант проголосовал пользователь
  def voted_for
    if voted_id && voted_id.zero?
      :none
    elsif voted_id == right_id && voted_id.nil?
      :auto
    elsif voted_id == left_id
      :left
    elsif voted_id == right_id
      :right
    else
      nil
    end
  end

  # за какой вариант проголосовал пользователь (работает при выборке со scope with_user_vote)
  def voted?
    voted_id.present? || (right_type.nil?)
  end

  # число голосов за левого кандидата
  def left_votes
    @left_votes ||= self[:left_votes] || cached_votes.select {|v| v.item_id == left_id }.size
  end

  # число голосов за правого кандидата
  def right_votes
    @right_votes ||= self[:right_votes] ||  cached_votes.select {|v| v.item_id == right_id }.size
  end

  # число голосов за правого кандидата
  def refrained_votes
    @refrained_votes ||= self[:refrained_votes] || cached_votes.select {|v| v.item_id == 0 }.size
  end

  # турнир голосования
  def contest
    @contest ||= round.contest
  end

  # стратегия турнира
  def strategy
    round.contest.strategy
  end

private
  def cached_votes
    @cached_votes ||= votes.all
  end
end
