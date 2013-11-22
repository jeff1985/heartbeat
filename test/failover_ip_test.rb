
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/failover_ip"

class FailoverIpTest < Test::Unit::TestCase
  def test_ip
    assert_equal "Ip", FailoverIp.new("Ip").ip
  end

  def test_initialize
    # Already tested
  end

  def test_current_target
    $config = Hashr.new(:base_url => "https://base_url", :basic_auth => "Basic auth")

    response = mock_object(:success? => true, :parsed_response => { "failover" => { "active_server_ip" => "Active server ip" }})

    mock(HTTParty).get("https://base_url/failover/Ip", :basic_auth => "Basic auth") { response }

    assert_equal "Active server ip", FailoverIp.new("Ip").current_target
  end

  def test_current_ping
    $config = Hashr.new(:ips => [
      { :ping => "Another ping", :target => "Another target" },
      { :ping => "Current ping", :target => "Current target" }
    ])

    $config.ips = $config.ips.collect { |ip| Hashr.new ip }

    mock.instance_of(FailoverIp).current_target { "Current target" }

    assert_equal "Current ping", FailoverIp.new("Ip").current_ping
  end

  def test_switch_to
    $config = Hashr.new(:base_url => "https://base_url", :basic_auth => "Basic auth")

    mock.instance_of(FailoverIp).current_target { "Current target" }

    mock(Hooks).run_before("Ip", "Current target", "Desired target")
    mock(Hooks).run_after("Ip", "Current target", "Desired target")

    mock(HTTParty).post("https://base_url/failover/Ip", :body => { :active_server_ip => "Desired target" }, :basic_auth => "Basic auth") { mock_object :success? => true }

    FailoverIp.new("Ip").switch_to "Desired target"
  end
end

