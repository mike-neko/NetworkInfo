Pod::Spec.new do |s|
  s.name = 'NetworkInfo'
  s.version = '0.0.1'
  s.summary = 'Network information in Swift.'
  s.homepage = 'https://github.com/mike-neko/NetworkInfo'
  s.license = 'MIT'
  s.author = 'mike-neko'
  
  s.ios.deployment_target = '9.2'
  
  s.source = { :git => 'https://github.com/mike-neko/NetworkInfo.git', :tag => s.version.to_s }
  s.source_files = 'Sources/*.{swift}'
  
  s.requires_arc = true
  s.library       = 'c'
  s.preserve_path = 'libc/*'
  s.pod_target_xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/NetworkInfo/libc' }
end