# encoding: utf-8
require "logstash/codecs/base"
require "logstash/namespace"
require "logstash/codecs/line"
Dir["#{File.expand_path('..', __FILE__)}/*.jar"].each { |jar| require(jar) }

# This  codec will append a string to the message field
# of an event, either in the decoding or encoding methods
#
# This is only intended to be used as an example.
#
# input {
#   stdin { codec =>  }
# }
#
# or
#
# output {
#   stdout { codec =>  }
# }
#
class LogStash::Codecs::SampleCodec < LogStash::Codecs::Base

  # The codec name
  config_name "sample-codec"

  # Append a string to the message
  config :append, :validate => :string, :default => ', Hello World!'

  def register
    @lines = LogStash::Codecs::Line.new
    @lines.charset = "UTF-8"
  end # def register

  def decode(data)
    @lines.decode(data) do |line|
      @out = Java::codec::Processor.parseInput(line.get("message").to_s)
      # replace = { "message" => line.get("message").to_s + @append }
      replace = { "message" => @out }
      yield LogStash::Event.new(replace)
    end
  end # def decode

  # Encode a single event, this returns the raw data to be returned as a String
  def encode_sync(event)
    event.get("message").to_s + @append + NL
  end # def encode_sync

end # class LogStash::Codecs::SampleCodec
