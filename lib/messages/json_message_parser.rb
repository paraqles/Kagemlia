require 'messages/message_parser.rb'

module JsonMessageParser
  include MessageParser

  def self.parse( string )
    begin
      msg  = JSON.parse( string )
    rescue
      return nil
    end
    return MessageParser.to_obj( msg )
  end
end
