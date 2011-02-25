require 'socket'
require 'Retriever'

class HTMLRetriever < Retriever

  def initialize( target )
    if target.matches( /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})+(:\d{1,5})?/ ).length > 1
      m = target.matches( /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})+(:\d{1,5})?/ )
      @target = m[0]
      @port = m[1][1..-1] if m[1] != ''
    elsif target.matches( /(http:\/\/)?(www\.)?(\w*\.\w{2,5})+(:\d{1,5})?/ ).length > 1
      m = target.matches( /(http:\/\/)?(www\.)?(\w*\.\w{2,5})+(:\d{1,5})?/ )
      @target = m[0] + m[1] + m[2]
      @port = m[3][1..-1] if m[3] != ''
    end
    @port ||= 80
  end

  def getPeers()
    
  end

end
