RSpec.describe 'filecollector' do

  framework_p = File.expand_path('./Resources/YYKit/YYKit.framework', File.dirname(__FILE__))
  r_header = File.expand_path('./Resources/YYKit', File.dirname(__FILE__))
  r_m = File.expand_path('./Resources/YYKit.build', File.dirname(__FILE__))
  f = VFS::FileCollector.new_from_real_headers_dir(Pathname(framework_p), Pathname(r_header), Pathname(r_m))
  w_p = File.expand_path('./Resources/cat.yaml', File.dirname(__FILE__))
  f.write_mapping(w_p)

  it 'file exist' do
    expect(w_p.exist?)
  end
end