
require "lib/failover_ip"
require "lib/ip_monitor"
require "lib/ip"

class Controller
  attr_accessor :failover_ip, :ip_monitor

  def initialize
    self.failover_ip = FailoverIp.new($config.failover_ip)
    self.ip_monitor = IpMonitor.new($config.ping_ip)
  end

  def responsible?
    current = failover_ip.current_ping

    if $config.ping_ip == current || $config.ping_ip == $config.failover_ip
      true
    else
      $logger.info "Not responsible for #{current}"

      false
    end
  end

  def next_ip
    target = failover_ip.current_target

    if index = $config.ips.index { |ip| ip.target == target }
      ($config.ips.size - 1).times do |i|
        ip = $config.ips[(index + i + 1) % $config.ips.size]

        return ip if Ip.new(ip.ping).up?
      end 
    end

    $logger.error "No more ips available"

    nil
  end

  def switch
    if new_ip = next_ip
      failover_ip.switch_to new_ip.target
    end
  end

  def start
    ip_monitor.monitor do
      switch if responsible?

      return if $config.only_once?
    end
  end
end

