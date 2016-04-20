Pod::Spec.new do |s|
  s.name         = 'SpectrumFaker'
  s.version      = '0.1.0'

  s.summary      = 'Mimics the behaviour of a spectrum analyzer. But with ony or two channels as input.'
  s.author       = { 'Roman Gille' => 'developer@romangille.com' }
  s.homepage     = 'https://github.com/r-dent/SpectrumFaker'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }

  s.source       = { :git => 'https://github.com/r-dent/SpectrumFaker.git', :tag => "v#{s.version}" }
  s.source_files = 'Sources/*.swift'

  s.requires_arc = true
  s.frameworks = 'UIKit'

  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8'
end