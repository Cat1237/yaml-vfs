RSpec.describe 'framework filecollector' do
  framework_p = File.expand_path('./Resources/YYKit/YYKit.framework', File.dirname(__FILE__))
  r_header = File.expand_path('./Resources/YYKit/YYKit', File.dirname(__FILE__))
  r_m = File.expand_path('./Resources/YYKit.build', File.dirname(__FILE__))
  entry = VFS::FileCollectorEntry.entrys_from_framework(Pathname(framework_p), Pathname(r_header), Pathname(r_m))
  w_p = File.expand_path('./Resources/cat.yaml', File.dirname(__FILE__))
  f = VFS::FileCollector.new(entry)
  f.write_mapping(w_p)

  it 'file exist' do
    expect(Pathname(w_p).exist?)
  end
end

RSpec.describe 'target filecollector' do
  target_p = File.expand_path('./Resources/YYKit/YYKit.app', File.dirname(__FILE__))
  r_pu = File.expand_path('./Resources/YYKit/Vendor', File.dirname(__FILE__))
  r_pr = File.expand_path('./Resources/YYKit/YYKit', File.dirname(__FILE__))
  entry = VFS::FileCollectorEntry.entrys_from_target(Pathname(target_p), Pathname(r_pu), Pathname(r_pr))
  w_p = File.expand_path('./Resources/app-cat.yaml', File.dirname(__FILE__))
  f = VFS::FileCollector.new(entry)
  f.write_mapping(w_p)

  it 'file exist' do
    expect(Pathname(w_p).exist?)
  end
end

