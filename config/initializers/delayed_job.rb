Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 30
Delayed::Worker.max_attempts = 2

Delayed::Worker.max_run_time = 24.hours

module Delayed
  class PerformableMailer < PerformableMethod
    def perform
      object.send(method_name, *args).deliver
    rescue Postmark::InvalidMessageError => e
      raise unless e.message =~ /Found inactive addresses/
    end
  end

  module Backend
    module ActiveRecord
      class Job
        def self.enqueue_uniq(*args)
          args.each do |job|
            next if Delayed::Job.where(:handler => job.to_yaml).count > 0
            enqueue(job)
          end
        end

        def status
          if self.last_error != nil
            'failed'
          elsif locked_at == nil
            'pending'
          else
            'executing'
          end
        end
      end
    end

    module Base
      module ClassMethods
        def reserve(worker, max_run_time = Worker.max_run_time)
          find_available(worker.name, 1, max_run_time).detect do |job|
            job.lock_exclusively!(max_run_time, worker.name)
          end
        end
      end
    end
  end
end
