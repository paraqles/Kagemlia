require 'rubygems'
require 'json'

require 'singleton'

class MessageParser
  include Singleton

  private

  def initialize
    @msgTypes = Array.new
  end

  public

  def self.i()
    self.instance
  end

  def parse( string )
    begin
      msg  = JSON.parse( string )
    rescue
      return nil
    end

    if not @msgTypes.include? msg['msgType']
      classname = msg['msgType']
      msgType = msg['msgType'].gsub( /^[A-Z]/) { $&.downcase  }
      msgType.gsub!( /[A-Z]/ ) { | m | m = '_' + m.downcase }

      if require( 'messages/datatypes/' + msgType + '.rb' )
        @msgTypes.push( classname )
      end
    end
    mesg = Kernel.const_get(classname).new( msg )
  end
end
