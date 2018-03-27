class People::JobsWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executed, queue: :cpu_intensive

  PEOPLE_WITH_CUSTOMIZED_ROLES_IDS = [6024]

  def perform
    Person.transaction do
      people.update_all producer: false, mangaka: false, seyu: false

      people.where(id: producer_ids).update_all producer: true
      people.where(id: mangaka_ids).update_all mangaka: true
      people.where(id: seyu_ids).update_all seyu: true
    end
  end

private

  def people
    Person.where.not(id: PEOPLE_WITH_CUSTOMIZED_ROLES_IDS)
  end

  def producer_ids
    PersonRole
      .where("
        role ilike 'Chief Producer' or
        role ilike 'Chief Producer,%' or
        role ilike '%, Chief Producer' or
        role ilike '%, Chief Producer,%' or
        role ilike 'Director' or
        role ilike 'Director,%' or
        role ilike '%, Director' or
        role ilike '%, Director,%'
      ")
      .pluck(:person_id)
      .uniq
  end

  def mangaka_ids
    PersonRole
      .where(role: Person::MANGAKA_ROLES)
      .pluck(:person_id)
      .uniq
  end

  def seyu_ids
    PersonRole
      .where(role: Person::SEYU_ROLES)
      .pluck(:person_id)
      .uniq
  end
end
