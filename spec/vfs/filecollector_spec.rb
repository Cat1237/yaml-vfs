RSpec.describe 'filecollector' do

  framework_p = File.expand_path('./Resources/YYKit/YYKit.framework', File.dirname(__FILE__))
  r_header = File.expand_path('./Resources/YYKit/YYKit', File.dirname(__FILE__))
  r_m = File.expand_path('./Resources/YYKit.build', File.dirname(__FILE__))
  entry = VFS::FileCollectorEntry.new_from_real_headers_dir(Pathname(framework_p), Pathname(r_m), Pathname(r_header))
  w_p = File.expand_path('./Resources/cat.yaml', File.dirname(__FILE__))
  f = VFS::FileCollector.new([entry])
  f.write_mapping(w_p)

  it 'file exist' do
    expect(Pathname(w_p).exist?)
  end
end
