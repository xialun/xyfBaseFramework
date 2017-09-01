Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.0"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license = 'MIT'

s.author       = { "wangshuai" => "1032188750@qq.com" }

s.platform     = :ios, "8.0"


s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.0" }


s.source_files = "DFTimelineView/DFTimelineView/**/*.{h,m}"




s.requires_arc = true

s.dependency 'DFCommon'
s.dependency 'AFNetworking', '~> 3.0.0'
s.dependency 'SDWebImage', '~> 3.7.3'
s.dependency 'FMDB', '~> 2.5'
s.dependency 'MBProgressHUD', '~> 0.9.1'
s.dependency 'MLLabel', '~> 1.7'

s.dependency 'MJRefresh', '~> 3.1.0'
s.dependency 'ODRefreshControl', '~> 1.2'
s.dependency 'MJPhotoBrowser', '~> 1.0.2'
s.dependency 'MMPopupView'
s.dependency 'TZImagePickerController'

end