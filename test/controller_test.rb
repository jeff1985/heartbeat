
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/controller"

class ControllerTest < Test::Unit::TestCase
  def test_failover_ip
    $config = base_config.merge(:failover_ip => "Failover ip")

    assert_equal "Failover ip", Controller.new.failover_ip.ip
  end

  def test_ip_monitor
    $config = base_config.merge(:ping_ip => "Ping ip")

    assert_equal "Ping ip", Controller.new.ip_monitor.ip
  end

  def test_initialize
    # Already tested
  end

  def test_responsible_ping_ip_equals_failover_ip
    $config = base_config.merge(:failover_ip => "Failover ip", :ping_ip => "Failover ip", :ips => [])

    set_current_target "Failover ip", "Another ip"

    assert Controller.new.responsible?
  end

  def test_responsible_current_ping_equals_ping_ip
    $config = base_config.merge(:failover_ip => "Failover ip", :ping_ip => "Ping ip", :ips => [Hashr.new(:ping => "Ping ip", :target => "Ping ip")])

    set_current_target "Failover ip", "Ping ip"

    assert Controller.new.responsible?
  end

  def test_not_responsible
    $config = base_config.merge(:failover_ip => "Failover ip", :ping_ip => "Ping ip", :ips => [Hashr.new(:ping_ip => "Another ip", :target => "Another ip")])

    set_current_target "Failover ip", "Another ip"

    refute Controller.new.responsible?
  end

  def test_next_ip  
    $config = base_config.merge(:failover_ip => "Failover ip", :ips => [
      Hashr.new(:ping => "Another ping", :target => "Another target"),
      Hashr.new(:ping => "Desired ping", :target => "Desired target"),
      Hashr.new(:ping => "Current ping", :target => "Current target")
    ])

    set_current_target "Failover ip", "Current target"

    set_down "Another ping"
    set_up "Desired ping"

    assert_equal Controller.new.next_ip, :ping => "Desired ping", :target => "Desired target"
  end

  def test_switch
    $config = base_config.merge(:failover_ip => "Failover ip", :ips => [
      Hashr.new(:ping => "Desired ping", :target => "Desired target"),
      Hashr.new(:ping => "Current ping", :target => "Current target")
    ])

    set_current_target "Failover ip", "Current target"
    set_switch_target "Failover ip", "Desired target"

    set_up "Desired ping"

    Controller.new.switch
  end

  def test_start
    $config = base_config.merge(:failover_ip => "Failover ip", :ping_ip => "Failover ip", :ips => [
      Hashr.new(:ping => "Current ping", :target => "Current target"),
      Hashr.new(:ping => "Another ping", :target => "Another target")
    ])

    set_down "Failover ip"

    mock.instance_of(Controller).switch { raise LeaveLoopException }

    assert_raise(LeaveLoopException) { Controller.new.start }
  end

  def test_start_only_once
    $config = base_config.merge(:failover_ip => "Failover ip", :ping_ip => "Current ping", :only_once => true, :ips => [
      Hashr.new(:ping => "Current ping", :target => "Current target"),
      Hashr.new(:ping => "Desired ping", :target => "Desired target")
    ])

    set_down "Current ping"
    set_up "Desired ping"

    set_current_target "Failover ip", "Current target"
    set_switch_target "Failover ip", "Desired target"

    Controller.new.start
  end
end

