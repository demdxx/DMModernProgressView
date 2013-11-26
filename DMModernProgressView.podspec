Pod::Spec.new do |s|
  s.name            = 'DMModernProgressView'
  s.author          = { "Dmitry Ponomarev" => "demdxx@gmail.com" }
  s.version         = '0.0.1'
  s.license         = 'MIT'
  s.summary         = 'iOS progress view'
  s.homepage        = 'https://github.com/demdxx/DMModernProgressView'
  s.source          = {:git => 'https://github.com/demdxx/DMModernProgressView.git', :tag => 'v0.0.1'}

  # Deployment
  s.platform        = :ios

  s.source_files    = 'Source/*.{h,m}'
  s.requires_arc    = false

  s.ios.frameworks  = 'Foundation', 'UIKit'
end