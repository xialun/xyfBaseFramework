Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.8"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license= { :type => "MIT", :file => "LICENSE" }

s.author       = { "wangshuai" => "1032188750@qq.com" }




s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.8" }


s.source_files  = "xyfBaseFramework/Database/*.{h,m}","xyfBaseFramework/Extensions/*.{h,m}","xyfBaseFramework/RSA/**","xyfBaseFramework/Security/*.{h,m}","xyfBaseFramework/System/*.{h,m}","xyfBaseFramework/network/*.{h,m}"

s.requires_arc = true

s.private_header_files  = "xyfBaseFramework/System/SCBaseObserveDefine.h"

s.platform     = :ios, "7.0"

s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FMDB', '~> 2.7.2'
s.frameworks = "UIKit", "Foundation"

end