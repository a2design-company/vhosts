raise 'No apache configuration found for node.' unless node['apache']
raise 'No vhosts configured for this node.' unless node['apache']['vhosts']

include_recipe 'apache2'

if node['apache']['vhosts'].is_a? Hash
  vhosts = node['apache']['vhosts'].collect do |title, vhost|
    vhost.merge title: title
  end
else
  vhosts = node['apache']['vhosts']
end

vhosts.each do |vhost|
  path = vhost['path'] || "/var/www/#{vhost['name']}/current/public"
  web_app vhost['name'] do
    template 'web_app.ssl.conf.erb'
    server_name vhost['name']
    server_aliases vhost['aliases']
    ssl (vhost['ssl'].nil? ? false : vhost['ssl'])
    domain vhost['domain']
    locations vhost['locations']
    path path
  end

  directory "#{path}" do
    owner node['apache']['user']
    group node['apache']['group']
    mode '0755'
    recursive true
  end
end
