#
# LWDynamicFont_swift.podspec
# Swift version of LWDynamicFont
#

Pod::Spec.new do |s|
  s.name             = 'LWDynamicFont_swift'
  s.version          = '1.0.0'
  s.summary          = 'Swift version of LWDynamicFont - A dynamic font loading and management library'

  s.description      = <<-DESC
LWDynamicFont_swift is a modern Swift/SwiftUI implementation of the LWDynamicFont library.
A comprehensive font management solution with:
- Dynamic font downloading from remote servers
- Font registration and management
- SwiftUI Font support
- UIKit UIFont support
- Font caching and persistence
- Progress tracking for downloads
- Async/await support
- Combine publishers for reactive updates
- Custom font fallback handling
                       DESC

  s.homepage         = 'https://github.com/luowei/LWDynamicFont.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWDynamicFont.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.swift_version = '5.0'

  s.source_files = 'LWDynamicFont_swift/Classes/**/*'

  s.frameworks = 'UIKit', 'CoreText', 'SwiftUI', 'Combine'
end
