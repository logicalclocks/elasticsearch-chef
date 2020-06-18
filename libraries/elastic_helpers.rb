module Elastic
  module Helpers

    def opendistro_security?
      return node['elastic']['opendistro_security']['enabled'].casecmp?("true")
    end

    def opendistro_security_https?
      return node['elastic']['opendistro_security']['https']['enabled'].casecmp?("true")
    end

    def all_elastic_nodes_dns()
      hosts = lookup_ips(all_elastic_ips())
      return hosts.map{|k, v| "CN=#{v},OU=*,O=Hopsworks,L=Stockholm,ST=Sweden,C=SE"}
    end

    def get_all_elastic_admin_dns()
      hosts = lookup_ips(all_elastic_ips())
      return hosts.map{|k, v| "CN=#{node["kagent"]["certs"]["elastic_admin_prefix"]}-#{v},OU=0,O=Hopsworks,L=Stockholm,ST=Sweden,C=SE"}
    end
    
    def all_elastic_host_names()
      hosts = lookup_ips(all_elastic_ips())
      return hosts.map{|k, v| v}
    end

    def my_host()
      return node["install"]["localhost"].casecmp?("true") ? "localhost" : node['fqdn']
    end

    def my_elastic_url()
      return get_elastic_url(my_private_ip())
    end

    def any_elastic_url()
      return all_elastic_urls()[0]
    end

    def all_elastic_ips()
      return private_recipe_ips("elastic", "default")
    end

    def all_elastic_ips_str()
      return all_elastic_ips().join(",")
    end

    def all_elastic_ips_ports_str()
      return all_elastic_ips().map { |e| "#{e}:#{node['elastic']['port']}"}.join(",")
    end

    def all_elastic_urls()
      return private_recipe_ips("elastic", "default").map{|e| get_elastic_url(e)}
    end

    def all_elastic_urls_str()
      return all_elastic_urls().map{|e| "\"#{e}\""}.join(",")
    end

    def get_elastic_url(elastic_ip)
      my_ip = my_private_ip()
      if opendistro_security?() && opendistro_security_https?()
        if my_ip.eql? elastic_ip
          return "https://#{my_host()}:#{node['elastic']['port']}"
        else
          hosts = lookup_ips([elastic_ip])
          return "https://#{hosts[elastic_ip]}:#{node['elastic']['port']}"
        end
      else
        return "http://#{elastic_ip}:#{node['elastic']['port']}"
      end
    end

    def lookup_ips(ips)
      hosts = Hash.new
      for ip in ips
        if ip.eql?(my_private_ip()) && node["install"]["localhost"].casecmp?("true")
          hosts[ip] = "localhost"
        else
          hosts[ip] = resolve_hostname(ip).to_s()
        end
      end
      return hosts
    end

    def get_my_es_master_uri()
      if opendistro_security?() && opendistro_security_https?()
        return "https://#{node['elastic']['opendistro_security']['elastic_exporter']['username']}:#{node['elastic']['opendistro_security']['elastic_exporter']['password']}@#{my_host()}:#{node['elastic']['port']}"
      elsif opendistro_security?()
        return "http://#{node['elastic']['opendistro_security']['elastic_exporter']['username']}:#{node['elastic']['opendistro_security']['elastic_exporter']['password']}@#{my_private_ip()}:#{node['elastic']['port']}"
      else
        return "http://#{my_private_ip()}:#{node['elastic']['port']}"
      end
    end

  end
end

Chef::Recipe.send(:include, Elastic::Helpers)
Chef::Resource.send(:include, Elastic::Helpers)
Chef::Provider.send(:include, Elastic::Helpers)
