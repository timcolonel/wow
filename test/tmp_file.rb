class TmpFile

  def self.clean(folder)
    FileUtils.rm_rf File.join(tmp_folder, folder)
  end
  #Return the path of a new file in the tmp folder
  def self.path(filename = '', folder = '')
    _folder = File.join(tmp_folder, folder)
    FileUtils.mkdir_p(_folder) unless File.directory?(_folder)
    File.join(_folder, "#{SecureRandom.uuid}-#{filename}")
  end

  def self.tmp_folder
    "#{File.dirname(__FILE__)}/tmp/"
  end

  def self.create_files(count: 1, folder: '')
    filenames = []
    count.times.each do |i|
      filename = path(i, folder)
      filenames << filename
      File.open filename, 'w' do |f|
        f.write Random.rand
      end
    end
    filenames
  end
end