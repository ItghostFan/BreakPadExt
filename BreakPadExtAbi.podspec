#
# Be sure to run `pod lib lint BreakPadExt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BreakPadExtAbi'
  s.version          = '0.1.0'
  s.summary          = 'BreakPadExt Binary Dependency.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
BreakPadExt Binary Dependency.
                       DESC

  s.homepage         = 'https://github.com/ItghostFan/BreakPadExt'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ItghostFan' => 'ItghostFan@163.com' }
  s.source           = { :http => 'https://github.com/ItghostFan/BreakPadExt/raw/main/bin/BreakPadExt-2022_04_10_22_07_20.zip' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  
  s.requires_arc = true

  s.default_subspec = 'Lib'
  
  s.subspec 'Lib' do |lib|
    lib.vendored_libraries = 'libBreakPadExt.a'
    lib.public_header_files = 'include/**/*.{h, hpp}'
    lib.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "\"${PODS_ROOT}/#{s.name}/include\"" }
    lib.user_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "\"${PODS_ROOT}/#{s.name}/include\"" }
  end
  
  s.subspec 'Dylib' do |dylib|
    dylib.vendored_frameworks = 'BreakPadExtDylib.framework'
    dylib.resources = 'BreakPadExtDylib.framework.dSYM'
    dylib.pod_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "\"${PODS_ROOT}/#{dylib.vendored_frameworks}/Headers\"" }
    dylib.user_target_xcconfig = { 'HEADER_SEARCH_PATHS' => "\"${PODS_ROOT}/#{dylib.vendored_frameworks}/Headers\"" }
  end
  
  # s.resource_bundles = {
  #   'BreakPadExt' => ['BreakPadExt/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.frameworks = 'Foundation'
  s.library = 'c++'
  # s.dependency 'AFNetworking', '~> 2.3'
end
