
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
    $config = base_config

    set_current_target "Ip", "Active server ip"

    assert_equal "Active server ip", FailoverIp.new("Ip").current_target
  end

  def test_current_ping
    $config = base_config.merge(:ips => [Hashr.new(:ping => "Another ping", :target => "Another target"), Hashr.new(:ping => "Current ping", :target => "Current target")])

    set_current_target "Ip", "Current target"

    assert_equal "Current ping", FailoverIp.new("Ip").current_ping
  end

  def test_switch_to
    $config = base_config

    set_current_target "Ip", "Current target"
    set_switch_target "Ip", "Desired target"

    assert_all_hooks_run do
      FailoverIp.new("Ip").switch_to "Desired target"
    end
  end
end

