Pod::Spec.new do |s|
  s.name = 'LambdaKit'
  s.version = '0.3.2'
  s.license = 'MIT'
  s.summary = 'Closures on most used UIKit methods'
  s.homepage = 'https://github.com/Reflejo/LambdaKit'
  s.social_media_url = 'https://twitter.com/fz'
  s.authors = { 'Martin Conte Mac Donell' => 'reflejo@gmail.com' }
  s.source = { :git => 'https://github.com/Reflejo/LambdaKit.git', :tag => s.version }

  s.ios.deployment_target = '10.0'
  s.watchos.deployment_target = '3.0'

  s.ios.source_files = 'Sources/LambdaKit/*.swift'
  s.watchos.source_files = 'Sources/LambdaKit/NSObject*.swift', 'Sources/LambdaKit/CLLocationManager*.swift'
end
