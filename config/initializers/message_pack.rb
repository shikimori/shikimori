require 'msgpack'

module MesagePackDumpFix
  def load value
    MessagePack.unpack value
  end

  def pg_load value
    MessagePack.unpack PG::Connection.unescape_bytea(value)
  end

  def dump value
    MessagePack.pack value
  end
end

MessagePack.send :extend, MesagePackDumpFix

module YAMLDumpFix
  def pg_load value
    YAML.load value
  end
end

YAML.send :extend, YAMLDumpFix
