require "minitest/autorun"
require "open3"
require "yaml"

class SiteTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  WORK_SLUGS = %w[guidehouse rpmc sun-life koru].freeze
  PAPER_SLUGS = %w[social-distancing energy-security hk-nationalism one-country-two-systems modernization-theory].freeze

  def read(path)
    File.read(File.join(ROOT, path))
  end

  def home_data
    @home_data ||= YAML.load_file(File.join(ROOT, "data/home.yml"))
  end

  def test_middleman_foundation_exists
    %w[Gemfile config.rb source/layouts/layout.erb source/stylesheets/site.css source/javascripts/site.js].each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_all_crawled_routes_exist
    paths = %w[source/index.html.md.erb data/home.yml]
    paths += WORK_SLUGS.map { |slug| "source/work/#{slug}/index.html.md.erb" }
    paths += PAPER_SLUGS.map { |slug| "source/papers/#{slug}/index.html.md.erb" }
    home_data["sections"].each { |section| paths << "source/partials/_#{section}.html.erb" }

    paths.each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
    end
  end

  def test_redesigned_shared_shell
    layout = read("source/layouts/layout.erb")
    %w[#expertise #work #research].each { |href| assert_includes layout, href }
    assert_includes layout, 'aria-label="Derron Yu home"'
    assert_includes layout, "brand-mark__d"
    assert_includes layout, "brand-mark__y"
    %w[Expertise Work Research].each { |label| assert_includes layout, label }
    assert_includes layout, "mailto:derron-nis@hotmail.com"
    refute_includes layout.downcase, "diamond"
    refute_includes layout, "Welcome To My Website!"
    assert_includes layout, 'javascript_include_tag "site"'
    refute_includes layout, "/skills/"
    refute_includes layout, "/papers/\""
    refute_includes layout, "/case-competitions/"
  end

  def test_home_page_is_data_driven
    home_erb = read("source/index.html.md.erb")
    assert_includes home_erb, "data.home"
    assert_includes home_erb, "home.sections.each"
    assert_includes home_erb, 'partial "partials/'
    refute_includes home_erb, "class=\"project-card"
  end

  def test_home_data_matches_expected_shape
    assert_equal home_data["sections"].sort, %w[background experience expertise research work].sort
    assert_equal 4, home_data["work"].length
    assert_equal 5, home_data["research"].length
    home_data["work"].each { |item| assert item["icon"], "expected work item #{item['title']} to have an icon" }
    home_data["research"].each { |item| refute item.key?("icon"), "research items should not carry an icon" }
  end

  def test_old_standalone_pages_are_gone
    %w[source/skills source/papers/index.html.md.erb source/case-competitions].each do |path|
      refute File.exist?(File.join(ROOT, path)), "expected #{path} to no longer exist"
    end
  end

  def test_page_content_matches_data
    assert_includes home_data["hero"]["intro"], "Master of Finance graduate of the Rotman School of Management"

    all_items = home_data["expertise"]["capabilities"].flat_map { |cap| cap["items"] }
    assert_includes all_items, "Google Analytics"

    work_titles = home_data["work"].map { |item| item["title"] }
    %w[Guidehouse\ Case\ Competition Rotman\ Portfolio\ Management\ Competition Problem\ Hunt\ Kickoff Sun\ Life\ Capital\ Management].each do |fragment|
      assert(work_titles.any? { |title| title.include?(fragment) }, "expected a work item matching #{fragment}")
    end

    assert_equal 5, home_data["research"].length
  end

  def test_redesigned_pages_preserve_useful_content
    home_erb = read("source/index.html.md.erb")
    assert_equal "I make complex ", home_data["hero"]["title_pre"]
    assert_equal "decisions clearer.", home_data["hero"]["title_contrast"]
    assert_includes home_data["hero"]["intro"], "Master of Finance"
    refute_includes home_erb, "evidence → action"

    capability_names = home_data["expertise"]["capabilities"].map { |cap| cap["name"] }
    assert_equal %w[Analysis Research Communication], capability_names
    intro = home_data["expertise"]["intro"]
    refute_match(/\d+%/, intro)
  end

  def test_research_and_work_detail_pages_preserve_the_full_original_narrative
    expected_by_slug = {
      "papers/social-distancing" => [
        "we make four broad contributions",
        "difference-in-difference regression equation"
      ],
      "papers/energy-security" => ["critical aspects of the global energy security equation"],
      "papers/hk-nationalism" => ["directly impacted the state of international diplomacy"],
      "papers/one-country-two-systems" => ["The conclusions I made were multifold"],
      "papers/modernization-theory" => [
        "John F Kennedy’s administration faced a multitude of complex issues",
        "Alliance for Progress program and the Strategic Hamlet Program"
      ],
      "work/rpmc" => [
        "two-phase challenge that tested my skills",
        "Managed a **$1 million CAD simulated portfolio",
        "**top-down strategy**"
      ],
      "work/guidehouse" => [
        "evaluating the feasibility of incentivizing new data centers",
        "One of the top 3 teams selected to present",
        "scalable suite model we proposed"
      ],
      "work/koru" => ["Koru’s methodology", "cutting client processing time by 50%", "premium, flexible solution that boosts efficiency"],
      "work/sun-life" => ["USD 500M pension fund", "currency-hedged ETFs (HEEM)", "recommending BOTZ for AI-driven investments"]
    }

    expected_by_slug.each do |slug, snippets|
      content = read("source/#{slug}/index.html.md.erb")
      snippets.each { |copy| assert_includes content, copy }
    end
  end

  def test_long_form_pages_are_authored_as_plain_markdown
    (WORK_SLUGS.map { |slug| "source/work/#{slug}/index.html.md.erb" } +
     PAPER_SLUGS.map { |slug| "source/papers/#{slug}/index.html.md.erb" }).each do |path|
      assert File.file?(File.join(ROOT, path)), "expected #{path} to exist"
      source = read(path)
      assert_includes source, "# "
      assert_includes source, "<div class=\"prose-page\" markdown=\"1\">"
    end
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
      "bundle", "exec", "middleman", "build", "--clean",
      chdir: ROOT
    )

    assert status.success?, "build failed:\n#{stdout}\n#{stderr}"

    homepage = read("build/index.html")
    stylesheet = read("build/stylesheets/site.css")
    guidehouse = read("build/work/guidehouse/index.html")
    social_distancing = read("build/papers/social-distancing/index.html")

    assert_includes homepage, 'href="/derron-website/work/guidehouse/"'
    assert_includes homepage, 'src="/derron-website/images/derron-yu.jpg"'
    assert_includes homepage, 'class="home-hero site-shell"'
    assert_includes homepage, 'class="brand-mark"'
    assert_includes stylesheet, 'url("../fonts/inter.woff2")'
    assert_includes stylesheet, "--color-paper: #f2ead3"
    assert_includes stylesheet, "--color-ink: #17231c"
    assert_includes social_distancing, 'href="/derron-website/papers/ECO446-FinalWorkingPaper-DerronYu.pdf"'
    assert_includes guidehouse, 'src="/derron-website/images/guidehouse-team.jpeg"'
    refute_includes guidehouse, "/derron-website/derron-website/"
  ensure
    Open3.capture3("bundle", "exec", "middleman", "build", "--clean", chdir: ROOT)
  end
end
