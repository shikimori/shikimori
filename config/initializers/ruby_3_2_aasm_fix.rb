module AASM
  module Ruby3LiteralCompat
    def exec_subject
      raise(*record_error) unless record.respond_to?(subject, true)

      # record.method(subject).source_location.first.include?('rspec-mocks')

      parameters = record.method(subject).parameters
      has_keyword_args = parameters.any? { |(type, _)| type.to_s.starts_with? "key" }

      if has_keyword_args && args.any? && args.last.extractable_options?
        kwargs = args.last
        fixed_args = args[0..-2]
      else
        kwargs = {}
        fixed_args = parameters.any? ? args : []
      end

      return record.send(subject) if args.none? && kwargs.none?

      record.send(subject, *fixed_args, **kwargs)
    rescue ArgumentError
      if Rails.env.test? && record.method(subject).source_location.first.include?('rspec-mocks')
        record.send(subject)
      else
        raise
      end
    end
  end

  # module Ruby3ProcCompat
  #   def exec_proc(parameters_size)
  #     kwargs = {}
  #     has_keyword_args = subject.parameters.any? { |(type, _)| type.to_s.starts_with? "key" }
  #     if has_keyword_args
  #       kwargs = args.extract_options!
  #       parameters_size -= 1 if !kwargs.empty? && parameters_size > 0
  #     end
  # 
  #     return record.instance_exec(&subject) if parameters_size.zero?
  #     return record.instance_exec(*args, **kwargs, &subject) if parameters_size < 0
  #     record.instance_exec(*args[0..(parameters_size - 1)], **kwargs, &subject)
  #   end
  # end
end

AASM::Core::Invokers::LiteralInvoker.prepend AASM::Ruby3LiteralCompat
