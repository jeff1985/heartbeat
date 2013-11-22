
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/ip_monitor"

class IpMonitorTest < Test::Unit::TestCase
  def setup
    $config = Hashr.new(:timeout => 1, :interval => 1, :down_interval => 1, :tries => 1)
  end

  def test_ip
    assert_equal "Ip", IpMonitor.new("Ip").ip
  end

  def test_initialize
    # Already tested
  end

  def test_check
    assert IpMonitor.new("8.8.8.8").check
    refute IpMonitor.new("1.1.1.1").check

    $config.force_down = true

    refute IpMonitor.new("8.8.8.8").check
  end

  def test_monitor_once_up
    $config.interval = 1

    IpMonitor.new("8.8.8.8").monitor_once
  end

  def test_monitor_once_down
    $config.down_interval = 1

    invoked = false

    IpMonitor.new("1.1.1.1").monitor_once { invoked = true }

    assert invoked
  end

  def test_monitor
    mock.instance_of(IpMonitor).check { raise LeaveLoopException }

    assert_raise(LeaveLoopException) { IpMonitor.new("8.8.8.8").monitor }
  end
end

