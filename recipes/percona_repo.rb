#
# Cookbook Name:: mysql
# Recipe:: percona_repo
#
# TODO: Add copyright info


case node['platform']
  when "ubuntu", "debian"
    include_recipe "apt"
    execute "add percona key to gpg" do
      command "gpg --keyserver keys.gnupg.net --homedir /root " +
	"--recv-keys #{node['mysql']['percona']['key_id']}"
      not_if "gpg --list-keys #{node['mysql']['percona']['key_id']}"
    end

    execute "add percona key to apt" do
      command "gpg --homedir /root --armor " +
	"--export #{node['mysql']['percona']['key_id']} | apt-key add -"
      not_if "apt-get key list #{node['mysql']['percona']['key_id']}"
    end

    apt_repository "percona" do
      distro = case node['platform']
	when "debian"
	  (node[:platform_version].to_i == 5) ? "lenny" : "squeeze"
	when "ubuntu"
	  # TODO: hammer out how the fuck best to get this for ubuntu
	end
      uri "http://repo.percona.com/apt"
      distribution distro
      components [ "main" ]
      key node['mysql']['percona']['key_id']
      action :add
    end
end
