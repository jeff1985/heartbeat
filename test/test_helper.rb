
require "rubygems"
require "bundler/setup"
require "test/unit"
require "fileutils"
require "logger"
require "hashr"
require "rr"

$logger = Logger.new(File.expand_path("../../log/test.log", __FILE__))

class LeaveLoopException < Exception; end

class Test::Unit::TestCase
  def base_config
    Hashr.new :base_url => "https://base_url", :basic_auth => "Basic auth", :tries => 1, :timeout => 1, :interval => 1, :down_interval => 1
  end

  def set_down(ip)
    mock.proxy(Ip).new(ip).at_least(1) { stub_object :up? => false, :down? => true }
  end

  def set_up(ip)
    mock.proxy(Ip).new(ip).at_least(1) { stub_object :up? => true, :down? => false }
  end

  def set_current_target(failover_ip, current_target)
    response = stub_object(:success? => true, :parsed_response => { "failover" => { "active_server_ip" => current_target }})

    mock(HTTParty).get("https://base_url/failover/#{failover_ip}", :basic_auth => "Basic auth").at_least(1) { response }
  end

  def set_switch_target(failover_ip, target)
    mock(HTTParty).post("https://base_url/failover/#{failover_ip}", :body => { :active_server_ip => target }, :basic_auth => "Basic auth") { stub_object :success? => true }
  end

  def mock_object(attributes = {})
    Object.new.tap do |object|
      m = mock(object)

      attributes.each do |key, value|
        m.method_missing(key) { value }
      end
    end
  end

  def stub_object(attributes = {})
    Object.new.tap do |object|
      m = stub(object)

      attributes.each do |key, value|
        m.method_missing(key) { value }
      end
    end
  end

  def assert_all_hooks_run
    assert_hooks_run "before" do
      assert_hooks_run "after" do
        yield
      end
    end
  end

  def assert_hooks_run(kind)
    hooks = File.expand_path("../../hooks", __FILE__)

    hook_scripts = ["hook1", "hook2"].collect { |file| File.join hooks, kind, file }
    hook_results = ["hook1", "hook2"].collect { |file| File.join "/tmp", kind, file }

    Hash[hook_scripts.zip(hook_results)].each do |script, result|
      open script, "w" do |stream|
        stream.write <<EOF
#!/bin/sh

echo "$1, $2, $3" > #{result}
EOF
      end

      FileUtils.mkdir_p File.dirname(result)
      FileUtils.chmod 0755, script
    end

    begin
      yield

      hook_results.each { |file| assert File.read(file) =~ /\A.*, .*, .*\Z/ }
    ensure
      [hook_scripts, hook_results].flatten.each { |file| FileUtils.rm_f file }
    end
  end

  def refute(boolean)
    assert !boolean
  end
end

