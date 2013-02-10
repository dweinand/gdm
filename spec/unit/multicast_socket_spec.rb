require 'spec_helper'
require 'multicast_socket'

describe MulticastSocket do
  
  describe "socket options" do
    
    def with_fake_socket
      MulticastSocket.send :const_set, :UDPSocket, FakeSocket
      yield MulticastSocket.new(3000)
    ensure
      MulticastSocket.send :remove_const, :UDPSocket
    end
    
    it "sets multicast ttl" do
      with_fake_socket do |s|
        s.socket.socket_options.must_include [
          Socket::IPPROTO_IP,
          Socket::IP_MULTICAST_TTL,
          1
        ]     
      end
    end
    
    it "sets reuse port" do
      with_fake_socket do |s|
        s.socket.socket_options.must_include [
          Socket::SOL_SOCKET,
          Socket::SO_REUSEPORT,
          1
        ]
      end
    end
    
    it "sets multicast membership" do
      with_fake_socket do |s|
        s.socket.socket_options.must_include [
          Socket::IPPROTO_IP,
          Socket::IP_ADD_MEMBERSHIP,
          s.multicast_group
        ]
      end
    end
    
  end
  
  describe "#send" do
    
    def address
      "239.255.255.250"
    end
    
    def port
      3000
    end
    
    it  "sends data to correct address and port" do
      msg = "MESSAGE"
      m_socket = MulticastSocket.new(port, address)
      m_socket.socket = FakeSocket.new
      m_socket.send(msg)
      m_socket.socket.sent.must_include [msg, 0, address, port]
    end
    
  end
  
  describe "#receive" do
    
    def address
      "239.255.255.250"
    end
    
    def port
      3000
    end
    
    it "receives correct message from address and port" do
      msg = "MESSAGE"
      m_socket = MulticastSocket.new(port, address)
      m_socket.socket = FakeSocket.new(msg)
      m_socket.receive.must_include [msg]
    end
      
    it "yields correct message from address and port when block given" do
      msg = "MESSAGE"
      m_socket = MulticastSocket.new(port, address)
      m_socket.socket = FakeSocket.new(msg)
      m_socket.receive do |response|
        response.must_equal [msg]
      end
        
    end
      
  end
  
end