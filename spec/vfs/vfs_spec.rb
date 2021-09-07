# frozen_string_literal: true

RSpec.describe 'VFS' do
  it 'has a version number' do
    expect(VFS::VERSION).not_to be nil
  end
end
