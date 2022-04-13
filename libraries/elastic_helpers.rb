module Elastic
  module Helpers

    def opensearch_security?
      return node['elastic']['opensearch_security']['enabled'].casecmp?("true")
    end

    def opensearch_security_https?
      return node['elastic']['opensearch_security']['https']['enabled'].casecmp?("true")
    end

    def all_elastic_nodes_dns()
      hosts = lookup_ips(all_elastic_ips())
      return hosts.map{|k, v| "CN=#{v},OU=*,L=#{node['elastic']['user']},ST=Sweden,C=SE"}
    end

    def get_all_elastic_admin_dns()
      hosts = lookup_ips(all_elastic_ips())
      return hosts.map{|k, v| "CN=#{v},OU=0,L=#{node['elastic']['elk-user']},ST=Sweden,C=SE"}
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
      if opensearch_security?() && opensearch_security_https?()
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
      if opensearch_security?() && opensearch_security_https?()
        return "https://#{node['elastic']['opensearch_security']['elastic_exporter']['username']}:#{node['elastic']['opensearch_security']['elastic_exporter']['password']}@#{my_host()}:#{node['elastic']['port']}"
      elsif opensearch_security?()
        return "http://#{node['elastic']['opensearch_security']['elastic_exporter']['username']}:#{node['elastic']['opensearch_security']['elastic_exporter']['password']}@#{my_private_ip()}:#{node['elastic']['port']}"
      else
        return "http://#{my_private_ip()}:#{node['elastic']['port']}"
      end
    end

  end
end

Chef::Recipe.send(:include, Elastic::Helpers)
Chef::Resource.send(:include, Elastic::Helpers)
Chef::Provider.send(:include, Elastic::Helpers)
