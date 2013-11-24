
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/ip_monitor"

class IpMonitorTest < Test::Unit::TestCase
  def setup
    $config = base_config
  end

  def test_ip
    assert_equal "Ip", IpMonitor.new("Ip").ip
  end

  def test_initialize
    # Already tested
  end

  def test_check
    set_up "Available ip"
    assert IpMonitor.new("Available ip").check

    set_down "Unavailable ip"
    refute IpMonitor.new("Unavailable ip").check

    $config.force_down = true

    refute IpMonitor.new("Available ip").check
  end

  def test_monitor_once_up
    set_up "Available ip"

    IpMonitor.new("Available ip").monitor_once
  end

  def test_monitor_once_down
    invoked = false

    set_down "Unavailable ip"

    IpMonitor.new("Unavailable ip").monitor_once { invoked = true }

    assert invoked
  end

  def test_monitor
    mock.instance_of(IpMonitor).monitor_once { raise LeaveLoopException }

    assert_raise(LeaveLoopException) { IpMonitor.new("Ip").monitor }
  end
end

