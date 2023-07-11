#
# Be sure to run `pod lib lint WDTouchID.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WDTouchID'
  s.version          = '0.1.2'
  s.summary          = 'WDTouchID is a framework for quickly integrating biometric fingerprints.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
WDTouchID is a framework for quickly integrating biometric fingerprints.
I wrote it for learning purposes, and I hope you can provide valuable comments.
                       DESC

  s.homepage         = 'https://github.com/jocelen/WDTouchID'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jocelen' => 'jocelen@163.com' }
  s.source           = { :git => 'https://github.com/jocelen/WDTouchID.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WDTouchID/Classes/**/*'
  
  # s.resource_bundles = {
  #   'WDTouchID' => ['WDTouchID/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
