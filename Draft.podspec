#
# Be sure to run `pod lib lint Draft.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Draft'
  s.version          = '0.1.0'
  s.summary          = 'A short description of Draft.'

  s.description      = <<-DESC
Lightweight, protocol-oriented networking in Swift.
                       DESC

  s.homepage         = 'https://github.com/cuappdev/Draft'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Daniel Li' => 'dl743@cornell.edu' }
  s.source           = { :git => 'https://github.com/cuappdev/Draft.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'Draft/Classes/**/*'
  
end
