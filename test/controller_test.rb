
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/controller"

class ControllerTest < Test::Unit::TestCase
  def test_failover_ip
    $config = Hashr.new(:failover_ip => "Failover ip")

    assert_equal "Failover ip", Controller.new.failover_ip.ip
  end

  def test_ip_monitor
    $config = Hashr.new(:ping_ip => "Ping ip")

    assert_equal "Ping ip", Controller.new.ip_monitor.ip
  end

  def test_initialize
    # Already tested
  end

  def test_responsible_ping_ip_equals_failover_ip
    $config = Hashr.new(:failover_ip => "Failover ip", :ping_ip => "Failover ip")

    mock.instance_of(FailoverIp).current_ping { "Another ip" }

    assert Controller.new.responsible?
  end

  def test_responsible_current_ping_equals_ping_ip
    $config = Hashr.new(:failover_ip => "Failover ip", :ping_ip => "Ping ip")

    mock.instance_of(FailoverIp).current_ping { "Ping ip" }

    assert Controller.new.responsible?
  end

  def test_not_responsible
    $config = Hashr.new(:failover_ip => "Failover ip", :ping_ip => "Ping ip")

    mock.instance_of(FailoverIp).current_ping { "Another ip" }

    refute Controller.new.responsible?
  end

  def test_next_ip  
    $config = Hashr.new(:ips => [
      { :ping => "Another ping", :target => "Another target" },
      { :ping => "Desired ping", :target => "Desired target" },
      { :ping => "Current ping", :target => "Current target" }
    ])

    $config.ips = $config.ips.collect { |ip| Hashr.new ip }

    mock.instance_of(FailoverIp).current_target { "Current target" }

    mock(Ip).new("Another ping").mock!.up? { false }
    mock(Ip).new("Desired ping").mock!.up? { true }

    assert_equal Controller.new.next_ip, :ping => "Desired ping", :target => "Desired target"
  end

  def test_switch
    mock.instance_of(Controller).next_ip.mock!.target { "Next ip" }
    mock.instance_of(FailoverIp).switch_to("Next ip")

    Controller.new.switch
  end

  def test_start
    $config = Hashr.new(:ping_ip => "Ping ip", :down_interval => 1)

    mock.instance_of(Ip).down? { true }
    mock.instance_of(Controller).responsible? { true }
    mock.instance_of(Controller).switch { raise LeaveLoopException }

    assert_raise(LeaveLoopException) { Controller.new.start }
  end

  def test_start_only_once
    $config = Hashr.new(:ping_ip => "Ping ip", :only_once => true)

    mock.instance_of(Ip).down? { true }
    mock.instance_of(Controller).responsible? { true }
    mock.instance_of(Controller).switch { true }

    Controller.new.start
  end
end

