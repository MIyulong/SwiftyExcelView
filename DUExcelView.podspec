#
# Be sure to run `pod lib lint DUAdLauncher.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DUExcelView'
  s.version          = '0.0.1'
  s.summary          = 'excel视图样式、支持头部与做左边固定'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  excel视图样式、支持自定义头部与做左边固定，cell样式自定义  
                       DESC

  s.homepage         = 'https://pkg.poizon.com/duapp/iOS/duexcelview.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'yulong' => '617352010@qq.com' }
  s.source           = { :git => 'git@pkg.poizon.com:duapp/iOS/duexcelview.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = "5.0"
  s.source_files = 'DUExcelView/Classes/**/*'

  s.static_framework = true
  
end
