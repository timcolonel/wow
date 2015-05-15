require 'test/test_helper'
class Wow::Package::SpecificationTest < ActiveSupport::TestCase
  def setup
    TmpFile.clean folder
    change_asset_folder(File.expand_path('../assets', __FILE__))
  end

  def folder
    'test_package_config'
  end

  def asset(path)
    File.join(File.dirname(__FILE__), path)
  end

  test 'should parse toml file' do
    hash = {name: 'Some name', version: '1.2.3', author: 'Some author'}
    tmp = TmpFile.path('package.toml', self.folder)
    erb = Renderer::ERB.render_file(asset('assets/package_config.toml.erb'), hash)
    File.write(tmp, erb)
    config = Wow::Package::Specification.new(:any)
    config.init_from_toml(tmp)
    assert_equal hash[:name], config.name
    assert_equal hash[:version], config.version
    assert_includes config.authors, hash[:author]
  end

  test 'should list all files' do
    config = Wow::Package::Specification.new
    config.files_included << 'assets/*.*'
    assert_not config.files.empty?
    assert config.files.include? 'assets/platforms.yml'
  end

  test 'should list all files in folder' do
    config = Wow::Package::Specification.new
    config.files_included << 'assets/'
    assert_not config.files.empty?
    assert config.files.include? 'assets/platforms.yml'
  end

  test 'validate should fail without name' do
    config = Wow::Package::Specification.new
    config.version = '1.0.0'
    assert_not config.valid?
  end

  test 'validate should fail with bad name' do
    config = Wow::Package::Specification.new
    config.name = 'Bad name with space'
    config.version = '1.0.0'
    assert_not config.valid?
  end

  test 'validate should fail without version' do
    config = Wow::Package::Specification.new
    config.name = 'super_name'
    assert_not config.valid?
  end

  test 'validate should fail with absolute path' do
    config = Wow::Package::Specification.new
    config.name = 'super_name'
    config.version = '1.0.0'
    config.files_included << '/absolute/path'
    assert_not config.valid?
  end

  test 'validate should succeed' do
    config = Wow::Package::Specification.new
    config.name = 'super_name'
    config.version = '1.0.0'
    config.files_included << 'relative/path'
    assert config.valid?, "Should be valid!, #{config.errors.full_messages}"
  end

  test 'should create archive from config' do
    config = Wow::Package::Specification.new
    config.name = 'from_archive'
    config.version = '1.0.0'
    filenames = TmpFile.create_files(count: 5, :folder => File.join(folder, 'input'), absolute: false)
    config.files_included = filenames
    archive = config.create_archive(TmpFile.folder_path(folder))
    assert File.exists?(archive)
  end

  test 'should install to installation folder' do
    config = Wow::Package::Specification.new
    config.name = 'to_install'
    config.version = '1.0.0'
    filenames = TmpFile.create_files(:count => 5, folder: File.join(folder, 'input'), absolute: false)
    config.files_included = filenames
    destination = File.join(TmpFile.folder_path(folder), 'output')
    config.install_to(destination)
    filenames.each do |filename|
      assert File.exists?(File.join(Wow::Config::ROOT_FOLDER, filename)), "File #{filename} should exists in #{destination} but doesn't"
    end
  end

  test 'should create config from string' do
    config = Wow::Package::Specification.new
    filename = 'dumfile.txt'
    config.init_from_rb("file '#{filename}'")
    assert config.files_included.include?(filename)
  end


  test 'archive name with no platform or any' do
    config = Wow::Package::Specification.new
    params = {name: Faker::App.name, version: '1.2.3'}
    config.init_from_hash(params)
    assert_equal "#{params[:name]}-#{params[:version]}.wow", config.archive_name
  end

  test 'archive name with platform' do
    platform = :unix
    config = Wow::Package::Specification.new(platform)
    params = {name: Faker::Name.name, version: '1.2.3'}
    config.init_from_hash(params)
    assert_equal "#{params[:name]}-#{params[:version]}-#{platform}.wow", config.archive_name
  end

end