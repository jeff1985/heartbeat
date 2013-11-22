
class Ip
  attr_accessor :ip

  def initialize(ip)
    self.ip = ip
  end

  def up?
    `ping -W #{$config.timeout || 10} -c #{$config.tries || 3} #{ip}`

    $?.success?
  end 

  def down?
    !up?
  end
end

