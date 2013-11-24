
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/failover_ip"

class FailoverIpTest < Test::Unit::TestCase
  def test_ip
    assert_equal "Failover ip", FailoverIp.new("Failover ip").ip
  end

  def test_initialize
    # Already tested
  end

  def test_current_target
    $config = base_config

    set_current_target "Failover ip", "Active server ip"

    assert_equal "Active server ip", FailoverIp.new("Failover ip").current_target
  end

  def test_current_ping
    $config = base_config.merge(:ips => [Hashr.new(:ping => "Another ping", :target => "Another target"), Hashr.new(:ping => "Current ping", :target => "Current target")])

    set_current_target "Failover ip", "Current target"

    assert_equal "Current ping", FailoverIp.new("Failover ip").current_ping
  end

  def test_switch_to
    $config = base_config

    set_current_target "Failover ip", "Current target"
    set_switch_target "Failover ip", "Desired target"

    assert_all_hooks_run do
      FailoverIp.new("Failover ip").switch_to "Desired target"
    end
  end
end

