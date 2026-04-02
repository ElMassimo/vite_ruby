# frozen_string_literal: true

require "test_helper"
require "fileutils"

RAKE_TASKS_BIN = File.expand_path("../bin/rake", __dir__)

ENGINE_TASKS_SSR_ENTRYPOINT = <<~SSR
  import http from 'http'

  const server = http.createServer((req, res) => {
    res.writeHead(200)
    res.end('Hello, World!!!')
  })

  server.listen(8080)
SSR

describe "EngineRakeTasks" do
  include ViteRubyTestHelpers

  let(:mounted_app_path) { Pathname.new(File.expand_path("mounted_app", __dir__)) }
  let(:root_dir) { mounted_app_path.join("test/dummy") }
  let(:gitignore_path) { root_dir.join(".gitignore") }
  let(:vite_binstub_path) { root_dir.join("bin/vite") }
  let(:vite_config_ts_path) { root_dir.join("vite.config.ts") }
  let(:procfile_dev) { root_dir.join("Procfile.dev") }
  let(:app_frontend_dir) { root_dir.join("app/frontend") }
  let(:app_public_dir) { root_dir.join("public/vite-dev") }
  let(:app_ssr_dir) { root_dir.join("public/vite-ssr") }
  let(:tmp_dir) { root_dir.join("tmp") }

  before do
    remove_vite_files
  end

  after do |_error|
    remove_vite_files
  end

  def within_mounted_app(&block)
    Dir.chdir(mounted_app_path, &block)
  end

  def within_mounted_app_root(&block)
    Dir.chdir(mounted_app_path.join("test/dummy"), &block)
  end

  def stub_runner(*args, **opts)
    status = MockProcessStatus.new
    if args.first == "build"
      extra_args = args[1..]
      captured = nil
      original = ViteRuby::Builder.instance_method(:build_with_vite)
      ViteRuby::Builder.define_method(:build_with_vite) { |*actual_args|
        captured = actual_args
 ["stdout", "", status]
      }
      begin
        yield
      ensure
        ViteRuby::Builder.define_method(:build_with_vite, original)
      end
      expect(captured).to be == extra_args
    else
      expected = [args, opts].flatten.reject(&:blank?)
      captured = nil
      original = ViteRuby.instance_method(:run)
      ViteRuby.define_method(:run) { |argv, **options|
        captured = [argv] + [options]
 ["stdout", "", status]
      }
      begin
        yield
      ensure
        ViteRuby.define_method(:run, original)
      end
      expect(captured.flatten.reject(&:blank?)).to be == expected
    end
  end

  def stub_kernel_exec(*command)
    captured = nil
    Kernel.stub(:exec, ->(*args) { captured = args }) { yield }
    expect(captured).to be == command
  end

  def remove_vite_files
    [vite_binstub_path, vite_config_ts_path, procfile_dev].each do |file|
      file.delete if file.exist?
    end
    [app_frontend_dir, app_public_dir, app_ssr_dir, tmp_dir].each do |dir|
      dir.rmtree if dir.exist?
    end
    root_dir.join("app/views/layouts/application.html.erb").write(Pathname.new(path_to_test_app).join("app/views/layouts/application.html.erb").read)
    gitignore_path.write("")
  end

  it "lists vite tasks when mounted" do
    output = within_mounted_app { `#{RAKE_TASKS_BIN} -T` }
    expect(output).to be(:include?, "app:vite")
  end

  it "runs rake tasks" do
    within_mounted_app { `#{RAKE_TASKS_BIN} app:vite:binstubs` }

    expect(vite_binstub_path).to be(:exist?)

    within_mounted_app_root { `bin/vite install` }

    expect(vite_config_ts_path).to be(:exist?)
    expect(procfile_dev).to be(:exist?)
    expect(app_frontend_dir).to be(:exist?)

    within_mounted_app { `#{RAKE_TASKS_BIN} app:vite:build` }

    expect(app_public_dir).to be(:exist?)
    expect(app_public_dir.join(".vite/manifest.json")).to be(:exist?)
    expect(app_public_dir.join("assets")).to be(:exist?)
    expect(app_ssr_dir).not.to be(:exist?)

    app_frontend_dir.join("ssr").mkdir
    app_frontend_dir.join("ssr/ssr.js").write(ENGINE_TASKS_SSR_ENTRYPOINT)

    within_mounted_app { `#{RAKE_TASKS_BIN} app:vite:build_all` }

    expect(app_ssr_dir.join("ssr.js")).to be(:exist?)
    expect(app_ssr_dir.join(".vite/manifest.json")).not.to be(:exist?)
    expect(app_ssr_dir.join(".vite/manifest-assets.json")).not.to be(:exist?)

    within_mounted_app { `#{RAKE_TASKS_BIN} app:vite:clobber` }

    expect(app_public_dir).not.to be(:exist?)
  end

  it "runs CLI commands" do
    within_mounted_app_root { `bundle exec vite install` }

    expect(vite_binstub_path).to be(:exist?)
    expect(vite_config_ts_path).to be(:exist?)
    expect(procfile_dev).to be(:exist?)
    expect(app_frontend_dir).to be(:exist?)

    within_mounted_app_root { `bin/vite build --mode development` }

    expect(app_public_dir).to be(:exist?)
    expect(app_public_dir.join(".vite/manifest.json")).to be(:exist?)
    expect(app_public_dir.join("assets")).to be(:exist?)

    version_output = within_mounted_app_root { `bin/vite version` }
    expect(version_output).to be(:include?, ViteRails::VERSION)
  end

  it "runs CLI command objects" do
    within_mounted_app_root do
      ViteRuby.commands.verify_install

      ENV["VITE_RUBY_ROOT"] = Dir.pwd
      refresh_config

      ViteRuby::CLI::Install.new.call
      ViteRuby.commands.verify_install
      ViteRuby::CLI::Version.new.call
      stub_kernel_exec("bundle exec vite upgrade_packages") {
        ViteRuby::CLI::Upgrade.new.call
      }
      ViteRuby::CLI::UpgradePackages.new.call

      stub_runner("build") {
        expect(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode)).to be_truthy
      }
      stub_runner("build", "--ssr") {
        expect(ViteRuby::CLI::Build.new.call(mode: ViteRuby.mode, ssr: true)).to be_truthy
      }

      FileUtils.mkdir_p(app_ssr_dir.to_s)
      ssr_path = app_ssr_dir.join("ssr.js")
      ssr_path.write("")
      stub_kernel_exec("node", ssr_path.to_s) {
        ViteRuby::CLI::SSR.new.call(mode: ViteRuby.mode)
      }

      stub_runner("--wat", exec: true) {
        expect(ViteRuby::CLI::Dev.new.call(mode: ViteRuby.mode, args: ["--wat"])).to be_truthy
      }

      ViteRuby::CLI::Clobber.new.call(mode: ViteRuby.mode)
    end
  ensure
    ENV.delete("VITE_RUBY_ROOT")
    refresh_config
  end
end
