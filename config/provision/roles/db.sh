<% @sun.role_recipes(%W(
  bootstrap/all
  user/deployer
  db/postgres__POSTGRES__
  lang/ruby/system__RUBY__
  utils/all
)) do |name, id| %>

  sun.source_recipe "<%= name %>" <%= id %>

<% end %>
