class NamedLogger
  def self.method_missing name, *args
    if args.nil?
      super
    else
      @loggers ||= {}
      @loggers[name] ||= build_logger name
    end
  end

private
  def self.build_logger name
    logfile = File.open(Rails.root.join('log', "#{name}.log"), 'a')
    logfile.sync = true

    logger = NamedLoggerProxy.new ActiveSupport::Logger.new(logfile)
    logger.formatter = CommonLogFormatter.new
    logger
  end
end

class NamedLoggerProxy < SimpleDelegator
  def info text, *args
    puts text
    super
  end
end

class CommonLogFormatter < Logger::Formatter
  def call severity, time, progname, msg
    if severity == 'INFO'
      "[#{time.to_s :short}] #{msg2str msg}\n"
    else
      "[#{time.to_s :short}] %5s - #{msg2str msg}\n" % [severity]
    end
  end
end

class ColouredLogFormatter < Logger::Formatter
  SEVERITY_TO_COLOR_MAP = {'DEBUG'=>'32', 'INFO'=>'0;37', 'WARN'=>'35', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

  def call severity, time, progname, msg
    color = SEVERITY_TO_COLOR_MAP[severity]
    "\033[0;37m[%s] \033[#{color}m%5s - %s\033[0m\n" % [time.to_s(:short), severity, msg2str(msg)]
  end
end
