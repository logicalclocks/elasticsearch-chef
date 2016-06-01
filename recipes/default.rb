

bash "install_delete_plugin" do
  user "root"
  cwd node.elastic.home
    code <<-EOF
   set -e
   bin/plugin install delete-by-query
EOF
end

