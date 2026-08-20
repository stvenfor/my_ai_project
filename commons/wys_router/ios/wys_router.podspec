Pod::Spec.new do |s|
  s.name             = 'wys_router'
  s.version          = '1.0.0'
  s.summary          = 'Unified router plugin (FeatureModule + URL/native bridge)'
  s.homepage         = 'http://example.com'
  s.license          = { :type => 'MIT' }
  s.author           = { 'WYS' => 'dev@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
end
