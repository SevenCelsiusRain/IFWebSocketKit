#
# Be sure to run `pod lib lint IFWebSocketKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IFWebSocketKit'
  s.version          = '0.1.0'
  s.summary          = 'webSocket 组件'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
长链接--webSocket组件
                       DESC

  s.homepage         = 'https://ifgitlab.gwm.cn/iov-ios/IFWebSocketKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '张高磊' => 'mrglzh@yeah.net' }
  s.source           = { :git => 'http://gitlab.ifyou.net/iov-ios/IFWebSocketKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'IFWebSocketKit/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IFWebSocketKit' => ['IFWebSocketKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SocketRocket'
  s.dependency 'AFNetworking'
end
