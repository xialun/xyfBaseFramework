Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.0"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license = 'MIT'

s.author       = { "wangshuai" => "1032188750@qq.com" }

s.platform     = :ios, "8.0"


s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.0" }


s.source_files = "xyfBaseFramework/*"

s.public_header_files = "xyfBaseFramework/System/SCBaseObserveDefine.h"



s.requires_arc = true

s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FMDB', '~> 2.7.2'
s.frameworks = "UIKit", "Foundation"

end