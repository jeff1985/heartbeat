
require "lib/ip"

class IpMonitor
  attr_accessor :ip

  def initialize(ip)
    self.ip = ip
  end

  def check
    if $config.force_down? || Ip.new(ip).down?
      $logger.info "#{ip} is down"

      false
    else
      $logger.info "#{ip} is up"

      true
    end
  end

  def monitor_once
    if check
      sleep $config.interval || 30
    else
      yield

      sleep $config.down_interval || 300
    end
  end

  def monitor(&block)
    loop { monitor_once &block }
  end
end

