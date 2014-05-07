Pod::Spec.new do |s|
  s.name         = "LASIImageView"
  s.version      = "1.0"
  s.summary      = "Async Image View"
  s.platform     = :ios, '5.0'
  s.homepage     = "https://github.com/lukagabric/LASIImageView"
  s.source       = { :git => 'https://github.com/lukagabric/LASIImageView'}
  s.source_files = 'LASIImageView/Classes/LASIImageView/*.{h,m}'
  s.dependency 'ASIHTTPRequest'
  s.requires_arc = true
end