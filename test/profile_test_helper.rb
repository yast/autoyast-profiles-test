#
# Tests are validated with jing using an RNG schema from yast2-schema
#
require "rspec"
require "cheetah"
require "yaml"
require "tmpdir"

ENV["LANG"] = "en_US.UTF-8"

class ProfileTestHelper
  AUTOYAST_RNG_SCHEMA = "/usr/share/YaST2/schema/autoyast/rng/profile.rng"
  PROFILES_DIR = __dir__
  CORRECT_PROFILES_DIR = "correct"
  INCORRECT_PROFILES_DIR = "incorrect"
  REPOSITORIES_CONF = File.join(__dir__, "repos_conf.yml")
  TEMPORARY_DIRECTORY_TEMPLATE = "schema-validation"

  attr_reader :test_dir

  # New constructor for ProfileTestHelper class
  #
  # @param [String] directory name containing tests as found in *tests*
  #        (e.g., "Head", "sle-12-sp1", ...)
  def initialize(test_dir)
    raise "I'm sorry, you have to be root to run these tests" if Process.uid != 0

    @test_dir = test_dir
  end

  # Runs a XML validation check on given profile in given directory
  # returns list of errors or blank string in case of no errors found
  def validate_profile(profile, profile_dir)
    if @schema_file.nil?
      raise "Run prepare_schema_dir(tests_dir) first"
    elsif !File.exist?(@schema_file)
      raise "Schema #{@schema_file} does not exist"
    end

    puts "Checking #{profile} according to #{@schema_file}"

    begin
      Dir.chdir(profile_dir) do
        output = Cheetah.run "jing", @schema_file, profile,
          :stdout => :capture, :stderr => :capture
      end
      return ""
    rescue Cheetah::ExecutionFailed => e
      $stderr.puts e.stderr
      return e.stdout
    end
  end

  # Removes a temporary directory for the current object
  def cleanup
    raise "Do you really want to remove your runnign system?" if @temporary_root == "/"
    return unless File.exist?(@temporary_root)

    puts "Removing temporary directory #{@temporary_root}"
    FileUtils.rm_rf @temporary_root
  end

  # Prepares a testing environment for a given directory containing profiles.
  # Directories are named after products and there is a corresponding
  # configuration in #{REPOSITORIES_CONF} file.
  def prepare_schema_dir
    repo_config = YAML::load_file(REPOSITORIES_CONF)

    raise "Cannot find configuration in repo_conf.yml for #{@test_dir}" unless repo_config.key?(@test_dir)

    repo_config = repo_config[@test_dir]

    raise "Cannot find 'repository' in configuration for '#{@test_dir}'" unless repo_config["repository"]
    raise "Cannot find 'fallback_repository' in configuration for '#{@test_dir}'" unless repo_config["fallback_repository"]

    @temporary_root = Dir.mktmpdir "#{TEMPORARY_DIRECTORY_TEMPLATE}_#{@test_dir}_"
    puts "Test for #{@test_dir} will use temporary root #{@temporary_root}"

    runner = self
    RSpec.configure do |config|
      config.after(:suite) do
        runner.cleanup
      end
    end

    begin
      Dir.chdir(__dir__) do
        output = Cheetah.run "./scripts/install_package_from_repos.sh",
          @temporary_root, "yast2-schema",
          repo_config["repository"], repo_config["fallback_repository"],
          :stdout => :capture, :stderr => :capture
        puts output
      end
      @schema_file = File.join(@temporary_root, AUTOYAST_RNG_SCHEMA)
      puts "Test will use latest schema from: #{@schema_file}"
      return true
    rescue Cheetah::ExecutionFailed => e
      puts e.stdout
      $stderr.puts e.stderr
      return false
    end
  end

  # Validates given incorrect profile and returns all errors as text
  def validate_incorrect_profile(profile)
    profiles_dir = File.join(PROFILES_DIR, @test_dir, INCORRECT_PROFILES_DIR)
    validate_profile(profile, profiles_dir)
  end

  # Validates all profiles in the given directory
  def validate_correct_profiles
    profiles_dir = File.join(PROFILES_DIR, @test_dir, CORRECT_PROFILES_DIR)
    runner = self

    RSpec.context "When checking correct profiles stored in #{profiles_dir}," do
      Dir.glob(File.join(profiles_dir, "*.xml")) do |profile|
        describe "Profile #{profile}" do
          it "passes validation according to schema" do
            expect(runner.validate_profile(profile, profiles_dir)).to eq("")
          end
        end
      end
    end
  end
end
