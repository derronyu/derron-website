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
    %w[source/index.html.erb source/skills/index.html.erb source/papers/index.html.md.erb source/case-competitions/index.html.md.erb].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_redesigned_shared_shell
    layout = read("source/layouts/layout.erb")
    %w[/skills/ /papers/ /case-competitions/].each { |href| assert_includes layout, href }
    assert_includes layout, 'aria-label="Derron Yu home"'
    assert_includes layout, "brand-mark__d"
    assert_includes layout, "brand-mark__y"
    %w[Expertise Research Work].each { |label| assert_includes layout, label }
    assert_includes layout, "mailto:derron-nis@hotmail.com"
    refute_includes layout.downcase, "diamond"
    refute_includes layout, "Welcome To My Website!"
    assert_includes layout, 'javascript_include_tag "site"'
  end

  def test_page_content_matches_crawl
    assert_includes read("source/index.html.erb"), "Master of Finance graduate of the Rotman School of Management"
    assert_includes read("source/skills/index.html.erb"), "Google Analytics"
    assert_includes read("source/papers/index.html.md.erb"), "Effectiveness of Social Distancing Policies"
    assert_includes read("source/case-competitions/index.html.md.erb"), "Rotman Portfolio Management Competition"
    assert_includes read("source/case-competitions/index.html.md.erb"), "Guidehouse Case Competition"
    assert_includes read("source/case-competitions/index.html.md.erb"), "Problem Hunt Kickoff"
    assert_includes read("source/case-competitions/index.html.md.erb"), "Sun Life Capital Management"
  end

  def test_redesigned_pages_preserve_useful_content
    home = read("source/index.html.erb")
    headline = home[/<h1>(.*?)<\/h1>/m, 1].gsub(/<[^>]+>/, "")
    assert_equal "I make complex decisions clearer.", headline
    assert_includes home, "Master of Finance"
    assert_includes home, "Guidehouse Case Competition"
    refute_includes home, "evidence → action"

    skills = read("source/skills/index.html.erb")
    %w[Analysis Research Communication].each { |group| assert_includes skills, group }
    refute_match(/\d+%/, skills)

    papers = read("source/papers/index.html.md.erb")
    assert_equal 5, papers.scan(/^## /).length

    cases = read("source/case-competitions/index.html.md.erb")
    assert_equal 4, cases.scan(/^## /).length
  end

  def test_research_and_case_pages_preserve_the_full_original_narrative
    papers = read("source/papers/index.html.md.erb")
    [
      "Some of the more exciting papers that I’ve had the opportunity to write",
      "we make four broad contributions",
      "difference-in-difference regression equation",
      "critical aspects of the global energy security equation",
      "directly impacted the state of international diplomacy",
      "The conclusions I made were multifold",
      "John F Kennedy’s administration faced a multitude of complex issues",
      "Alliance for Progress program and the Strategic Hamlet Program"
    ].each { |copy| assert_includes papers, copy }

    cases = read("source/case-competitions/index.html.md.erb")
    [
      "two-phase challenge that tested my skills",
      "Managed a **$1 million CAD simulated portfolio",
      "**top-down strategy**",
      "evaluating the feasibility of incentivizing new data centers",
      "One of the top 3 teams selected to present",
      "scalable suite model we proposed",
      "Koru’s methodology",
      "cutting client processing time by 50%",
      "premium, flexible solution that boosts efficiency",
      "USD 500M pension fund",
      "currency-hedged ETFs (HEEM)",
      "recommending BOTZ for AI-driven investments"
    ].each { |copy| assert_includes cases, copy }
  end

  def test_long_form_pages_are_authored_as_plain_markdown
    %w[
      source/papers/index.html.md.erb
      source/case-competitions/index.html.md.erb
    ].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
      source = read(path)
      assert_includes source, "# "
      assert_includes source, "["
      refute_match(/class=/, source)
    end
    assert_includes read("source/case-competitions/index.html.md.erb"), "- "
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
    skip
    stdout, stderr, status = Open3.capture3(
      { "BASE_PATH" => "/derron-website" },
      "bundle", "exec", "middleman", "build",
      chdir: ROOT
    )

    assert status.success?, "build failed:\n#{stdout}\n#{stderr}"

    homepage = read("build/index.html")
    stylesheet = read("build/stylesheets/site.css")
    papers = read("build/papers/index.html")
    cases = read("build/case-competitions/index.html")

    assert_includes homepage, 'href="/derron-website/skills/"'
    assert_includes homepage, 'src="/derron-website/images/derron-yu.jpg"'
    assert_includes homepage, 'class="home-hero site-shell"'
    assert_includes homepage, 'class="brand-mark"'
    assert_includes stylesheet, 'url("../fonts/inter.woff2")'
    assert_includes stylesheet, "--color-paper: #f2ead3"
    assert_includes stylesheet, "--color-ink: #17231c"
    assert_includes stylesheet, "prefers-reduced-motion"
    assert_includes papers, 'href="/derron-website/papers/ECO446-FinalWorkingPaper-DerronYu.pdf"'
    assert_includes cases, 'src="/derron-website/images/guidehouse-team.jpeg"'
    refute_includes cases, "/derron-website/derron-website/"
  end
end
