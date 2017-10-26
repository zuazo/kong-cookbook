# Set Java defaults
default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['jdk']['8']['x86_64']['url'] = 'https://vw-java.s3.amazonaws.com/jdk-8u91-linux-x64.tar.gz'
default['java']['jdk']['8']['x86_64']['checksum'] = \
  '6f9b516addfc22907787896517e400a62f35e0de4a7b4d864b26b61dbe1b7552'
default['java']['oracle']['accept_oracle_download_terms'] = true
