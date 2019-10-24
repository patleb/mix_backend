module Cloud::Vagrant
  def vagrant_pkey
    vagrant_ssh_config.first.last['identity_file']
  end

  def vagrant_ssh_config
    @_vagrant_ssh_config ||= `vagrant ssh-config`.lines.split(&:blank?).reject(&:empty?).each_with_object({}) do |config, hosts|
      hosts[config.shift.split.last] = config.each_with_object({}) do |key_value, config|
        key, value = key_value.split
        config[key.underscore] = value
      end
    end
  end

  def vagrant_server_ips(filter)
    list = Pathname.new('/etc/hosts').readlines
    list.select!{ |line| true if (line =~ /vagrant-hostmanager-start/ .. line =~ /vagrant-hostmanager-end/) }
    list[1..-2].reject(&:blank?).select(&:include?.with(filter)).map(&:split).map(&:first)
  end
end
