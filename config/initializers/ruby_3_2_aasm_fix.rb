module AASM
  module Ruby3ProcCompat
    def exec_proc(parameters_size)
      kwargs = {}
      has_keyword_args = subject.parameters.any? { |(type, _)| type.to_s.starts_with? "key" }
      if has_keyword_args
        kwargs = args.extract_options!
        parameters_size -= 1 if !kwargs.empty? && parameters_size > 0
      end

      return record.instance_exec(&subject) if parameters_size.zero?
      return record.instance_exec(*args, **kwargs, &subject) if parameters_size < 0
      record.instance_exec(*args[0..(parameters_size - 1)], **kwargs, &subject)
    end
  end
end

AASM::Core::Invokers::ProcInvoker.prepend AASM::Ruby3ProcCompat
