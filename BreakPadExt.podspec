#
# Be sure to run `pod lib lint BreakPadExt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BreakPadExt'
  s.version          = '0.1.0'
  s.summary          = 'A short description of BreakPadExt.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ItghostFan/BreakPadExt'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ItghostFan' => 'ItghostFan@163.com' }
  s.source           = { :git => 'https://github.com/ItghostFan/BreakPadExt.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.prepare_command = <<-CMD
    bash "BreakPadExt/Shells/BreakPadExtConfig.sh"
#    echo "BreakPadExt ################################"
#    env
#    touch fucking.txt #echo `pwd`"##########"
#    echo `pwd`
  CMD

  s.ios.deployment_target = '9.0'
  
  s.requires_arc = true

  s.default_subspec = 'Core', 'Shells'
  
  s.subspec 'BreakPad' do |breakpad|
    breakpad.requires_arc = false
    breakpad.source_files = 'BreakPadExt/Classes/breakpad/**/*'
  end
  
  s.subspec 'Core' do |core|
    core.source_files = 'BreakPadExt/Classes/breakpadext/**/*'
    core.dependency 'BreakPadExt/BreakPad'
  end
  
  s.subspec 'Shells' do |shells|
    shells.resources = 'BreakPadExt/Shells/**/*'
  end
  
#  s.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BreakPadExt/BreakPadExt/Classes/breakpad/src"' }
#  s.user_target_xcconfig = { 'HEADER_SEARCH_PATHS' => '"${PODS_ROOT}/BreakPadExt/BreakPadExt/Classes/breakpad/src"' }
  
  # s.resource_bundles = {
  #   'BreakPadExt' => ['BreakPadExt/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.frameworks = 'Foundation'
  s.library = 'c++'
  # s.dependency 'AFNetworking', '~> 2.3'
end
