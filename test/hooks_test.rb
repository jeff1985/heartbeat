
$:.unshift File.expand_path("../..", __FILE__)

require "test/test_helper"
require "lib/hooks"

class HooksTest < Test::Unit::TestCase
  def test_run_before
    assert_hooks_run "before" do
      Hooks.run_before "Failover ip", "Old ip", "New ip"
    end
  end

  def test_run_after
    assert_hooks_run "after" do
      Hooks.run_after "Failover ip", "Old ip", "New ip"
    end
  end
end

