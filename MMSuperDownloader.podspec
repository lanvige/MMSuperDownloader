Pod::Spec.new do |s|
  s.name     = 'MMSuperDownloader'
  s.version  = '0.8.0'
  s.summary  = 'Download single or multi files through HTTP, and show the whole progress.'
  s.homepage = 'https://github.com/lanvige/MMSuperDownloader'
  s.authors  = { 'Lanvige Jiang' => 'lanvige@gmail.me' }
  s.source   = { :git => 'https://github.com/lanvige/MMSuperDownloader' }
  s.source_files = 'MMSuperDownloader'
  s.requires_arc = true

  s.ios.deployment_target = '5.0'
  
  s.dependency 'AFNetworking'
end