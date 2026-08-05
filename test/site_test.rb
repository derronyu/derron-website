require "minitest/autorun"
require "open3"

class SiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def read(path)
    File.read(File.join(ROOT, path))
  end

  def test_middleman_foundation_exists
    %w[Gemfile config.rb source/layouts/layout.erb source/stylesheets/site.css source/javascripts/site.js].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_all_crawled_routes_exist
    %w[source/index.html.erb source/skills/index.html.erb source/papers/index.html.erb source/case-competitions/index.html.erb].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_shared_layout_contains_navigation_and_footer
    layout = read("source/layouts/layout.erb")
    %w[/skills/ /papers/ /case-competitions/].each { |href| assert_includes layout, href }
    assert_includes layout, "Welcome To My Website!"
    assert_includes layout, 'javascript_include_tag "site"'
  end

  def test_page_content_matches_crawl
    assert_includes read("source/index.html.erb"), "Master of Finance candidate at the Rotman School of Management"
    assert_includes read("source/skills/index.html.erb"), "Google Analytics"
    assert_includes read("source/papers/index.html.erb"), "Effectiveness of Social Distancing Policies"
    assert_includes read("source/case-competitions/index.html.erb"), "Rotman Portfolio Management Competition"
    assert_includes read("source/case-competitions/index.html.erb"), "Guidehouse Case Competition"
    assert_includes read("source/case-competitions/index.html.erb"), "Problem Hunt Kickoff"
    assert_includes read("source/case-competitions/index.html.erb"), "Sun Life Capital Management"
  end

  def test_required_local_assets_exist
    %w[
      source/images/derron-yu.jpg
      source/images/rpmc.png
      source/images/guidehouse-team.jpeg
      source/images/guidehouse-deck.png
      source/images/koru.png
      source/images/sun-life.png
      source/fonts/inter.woff2
      source/fonts/cardo.woff2
      source/papers/ECO446-FinalWorkingPaper-DerronYu.pdf
      source/papers/TRN410-FinalWorkingPaper-DerronYu.pdf
      source/papers/TRN250-FinalWorkingPaper-DerronYu.pdf
      source/papers/HIS385-FinalWorkingPaper-DerronYu.pdf
      source/papers/HIS377-FinalWorkingPaper-DerronYu.pdf
    ].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_production_build_honors_a_hosting_base_path
    stdout, stderr, status = Open3.capture3(
      { "BASE_PATH" => "/derron-website" },
      "bundle", "exec", "middleman", "build",
      chdir: ROOT
    )

    assert status.success?, "build failed:\n#{stdout}\n#{stderr}"

    homepage = read("build/index.html")
    stylesheet = read("build/stylesheets/site.css")
    papers = read("build/papers/index.html")

    assert_includes homepage, 'href="/derron-website/skills/"'
    assert_includes homepage, 'src="/derron-website/images/derron-yu.jpg"'
    assert_includes stylesheet, 'url("../fonts/inter.woff2")'
    assert_includes papers, 'href="/derron-website/papers/ECO446-FinalWorkingPaper-DerronYu.pdf"'
  end
end
