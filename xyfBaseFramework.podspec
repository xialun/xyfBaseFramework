Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.1"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license = 'MIT'

s.author       = { "wangshuai" => "1032188750@qq.com" }

s.platform     = :ios, "8.0"


s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.1" }


s.source_files  = "xyfBaseFramework/Database/*.{h,m}","xyfBaseFramework/Extensions/*.{h,m}","xyfBaseFramework/RSA/*.{h,m}","xyfBaseFramework/Security/*.{h,m}","xyfBaseFramework/System/*.{h,m}","xyfBaseFramework/network/*.{h,m}"

s.public_header_files = "xyfBaseFramework/System/SCBaseObserveDefine.h"



s.requires_arc = true

s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FMDB', '~> 2.7.2'
s.frameworks = "UIKit", "Foundation"

end