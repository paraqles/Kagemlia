require 'json'

class MessageParser
  include Singleton

  private

  def initialize
    @msgTypes = Array.new
  end

  public

  def parse( string )
    begin
      msg  = JSON.parse( string )
    rescue
      return nil
    end

    if not @msgTypes.include? js['msgType']
      msgType = msg['msgType'].gsub!( /^[A-Z]/) { $&.downcase  }
      msgType.gsub!( /[A-Z]/ ) { | m | m = '_' + m.downcase }

      if load( '../datatype/' + msgType + '.rb' )
        @msgTypes.push( js['msgType'] )
      end
    end

    msg = (msg['msgType']).new
  end
end
