module Cloud::Openstack
  class InvalidCommand < ::StandardError; end
  class AlreadyCreated < ::StandardError; end
  class DoesNotExist < ::StandardError; end

  def openstack_server_create(flavor, network, project, env, app: nil, version: nil, count: 1)
    tag = [project, env, app].compact.join('_')
    keypair = "ssh-#{[project, env].join('-').dasherize}"
    snapshot = [project, version].compact.join('-')
    raise AlreadyCreated if openstack_server_list(tag).present?
    raise DoesNotExist if openstack_flavor_list(flavor).empty?
    raise DoesNotExist if (network = openstack_network_list(network).first).nil?
    raise DoesNotExist if (snapshot = openstack_snapshot_list(snapshot).first).nil?
    raise DoesNotExist if (security_group = openstack_security_group_list(project).first).nil?
    raise DoesNotExist if openstack_keypair_list(keypair).empty?
    openstack_execute(<<-CMD.squish).map(&:values).to_h.transform_keys(&:underscore).with_indifferent_access
      nova boot
        --flavor #{flavor}
        --nic net-id=#{network[:id]}
        --snapshot #{snapshot[:id]}
        --security-groups #{security_group[:name]}
        --key-name #{keypair}
        --min-count #{count}
        --poll
        #{tag}
    CMD
  end

  def openstack_server_destroy
    # TODO delete volumes as well
  end

  def openstack_server_ips(*filters)
    openstack_server_list(*filters).map do |row|
      row[:networks].split('=').last.split(',').first
    end
  end

  def openstack_server_volume_list
    "nova volume-attachments ..."
    # server name or id
  end

  def openstack_server_list(*filters)
    openstack_execute('nova list', *filters)
  end

  def openstack_flavor_list(*filters)
    openstack_execute('nova flavor-list', *filters)
  end

  def openstack_network_list(*filters)
    openstack_execute('openstack network list', *filters)
  end

  def openstack_snapshot_list(*filters)
    openstack_execute('openstack volume snapshot list', *filters)
  end

  def openstack_security_group_list(*filters)
    openstack_execute('openstack security group list', *filters)
  end

  def openstack_keypair_list(*filters)
    openstack_execute('openstack keypair list', *filters)
  end

  def openstack_execute(command, *filters)
    lines = `#{openstack_context} #{command}`.lines.select{ |line| line.start_with? '|' }
    raise InvalidCommand if lines.empty?
    openstack_rows(lines, *filters)
  end

  private

  def openstack_context
    Setting.select{ |k, _| k.start_with? 'os_' }.map{ |k, v| "#{k.upcase}='#{v}'" }.join(' ')
  end

  def openstack_rows(lines, *filters)
    header = openstack_cells(lines.shift).map(&:underscore)
    lines.each_with_object([]) do |line, rows|
      row = openstack_cells(line).each_with_object({}.with_indifferent_access).with_index do |(cell, row), i|
        row[header[i]] = cell
      end
      rows << row if filters.empty? || filters.all?{ |filter| row.any?{ |_, v| v.include? filter } }
    end
  end

  def openstack_cells(line)
    line.split('|')[1..-2].map(&:strip)
  end
end
