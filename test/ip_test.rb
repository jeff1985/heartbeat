
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/ip"

class IpTest < Test::Unit::TestCase
  def setup
    $config = Hashr.new(:timeout => 1, :tries => 1)
  end

  def test_ip
    assert_equal "Ip", Ip.new("Ip").ip
  end

  def test_initialize
    # Already tested
  end

  def test_up?
    assert Ip.new("8.8.8.8").up?
    refute Ip.new("1.1.1.1").up?
  end

  def test_down?
    assert Ip.new("1.1.1.1").down?
    refute Ip.new("8.8.8.8").down?
  end
end


