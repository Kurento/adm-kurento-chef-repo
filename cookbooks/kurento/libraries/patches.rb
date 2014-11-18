class ::Chef::Provider::Package::Rubygems
  def install_via_gem_command(name, version)
    # There are some mighty big packages in this recipe, and 600s is just not enough!
    if @new_resource.source =~ /\.gem$/i
            name = @new_resource.source
          else
            src = @new_resource.source && "  --source=#{@new_resource.source} --source=https://rubygems.org"
          end
          if version
            shell_out!("#{gem_binary_path} install #{name} -q --no-rdoc --no-ri -v \"#{version}\"#{src}#{opts}", :env=>nil, :log_level => :info, :timeout => 216000)
          else
            shell_out!("#{gem_binary_path} install \"#{name}\" -q --no-rdoc --no-ri #{src}#{opts}", :env=>nil, :log_level => :info, :timeout => 216000)
          end
  end

  def uninstall_via_gem_command(name, version)
    if version
      shell_out!("#{gem_binary_path} uninstall #{name} -q -x -I -v \"#{version}\"#{opts}", :env=>nil, :log_level => :info, :timeout => 216000)
    else
      shell_out!("#{gem_binary_path} uninstall #{name} -q -x -I -a#{opts}", :env=>nil, :log_level => :info, :timeout => 216000)
    end
  end

end

class ::Chef::Provider::Package::Apt
  def run_noninteractive(command)
    # There are some mighty big packages in this recipe, and 600s is just not enough!
    shell_out!(command, :env => { "DEBIAN_FRONTEND" => "noninteractive", "LC_ALL" => nil }, :log_level => :info, :timeout => 216000)
  end
end
