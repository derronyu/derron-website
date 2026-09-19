set :css_dir, "stylesheets"
set :js_dir, "javascripts"
set :images_dir, "images"
set :bind_address, "0.0.0.0"
set :port, 4174
set :http_prefix, ENV.fetch("BASE_PATH", "")

activate :directory_indexes

helpers do
  def site_path(path)
    "#{config[:http_prefix]}#{path}"
  end
end
