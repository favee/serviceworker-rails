module GeneratorTestHelpers
  def self.included(base)
    base.send :include, TestMethods
    base.extend ClassMethods
  end

  module TestMethods
    def sample_app_path(*paths)
      tmp_path("generator_sample", *paths)
    end

    def tmp_path(*paths)
      File.join(File.dirname(__FILE__), "..", "tmp", *paths)
    end

    def evaluate_erb_asset_template(template)
      engine = ::ERB.new(template)
      asset_binding = asset_context_class.new.instance_eval("binding")
      engine.result(asset_binding)
    end

    def asset_context_class
      Class.new do
        def image_path(name)
          "/assets/#{name}"
        end
      end
    end
  end

  module ClassMethods
    include TestMethods

    def create_generator_sample_app
      FileUtils.mkdir_p(tmp_path)
      FileUtils.cd(tmp_path) do
        system "rails new generator_sample --skip-active-record --skip-test-unit --skip-spring --skip-bundle --quiet"
        File.open(File.join(sample_app_path, "Gemfile"), "a") do |f|
          f.puts "gem 'serviceworker-rails', path: '#{File.join(File.dirname(__FILE__), "..", "..")}'"
        end
      end

      FileUtils.cd(sample_app_path) do
        system "bundle install --quiet"
      end
    end

    def install_serviceworker_rails
      FileUtils.cd(sample_app_path) do
        system "rails g serviceworker:install --quiet -f 2>&1"
      end
    end

    def remove_generator_sample_app
      FileUtils.rm_rf(tmp_path)
    end
  end
end
