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
    return Logger.new(nil) if Rails.env.test?

    logfile = File.open(Rails.root.join('log', "#{name}.log"), 'a')
    logfile.sync = true

    #logger = NamedLoggerProxy.new ActiveResource::BufferedLogger.new(logfile)
    logger = NamedLoggerProxy.new ActiveSupport::Logger.new(logfile)
    logger.formatter = CommonLogFormatter.new
    # logger.formatter = ColouredLogFormatter.new
    logger
  end
end

class NamedLoggerProxy < SimpleDelegator
  def debug text, *args
    puts text unless Rails.env.test?
    super
  end

  def info text, *args
    puts text unless Rails.env.test?
    super
  end
end

class CommonLogFormatter < Logger::Formatter
  TIME_FORMAT = '%Y-%m-%d %H:%M'

  def call severity, time, progname, msg
    if severity == 'INFO'
      "[#{time.strftime TIME_FORMAT}] #{msg2str msg}\n"
    else
      formatted_severity = "%5s" % severity
      "[#{time.strftime TIME_FORMAT}] #{formatted_severity} - #{msg2str msg}\n"
    end
  end
end

class ColouredLogFormatter < Logger::Formatter
  TIME_FORMAT = CommonLogFormatter::TIME_FORMAT
  SEVERITY_TO_COLOR_MAP = {'DEBUG'=>'32', 'INFO'=>'0;37', 'WARN'=>'35', 'ERROR'=>'31', 'FATAL'=>'31', 'UNKNOWN'=>'37'}

  def call severity, time, progname, msg
    color = SEVERITY_TO_COLOR_MAP[severity]
    "\033[0;37m[%s] \033[#{color}m%5s - %s\033[0m\n" % [time.strftime(TIME_FORMAT), severity, msg2str(msg)]
  end
end
