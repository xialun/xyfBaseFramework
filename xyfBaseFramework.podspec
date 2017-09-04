Pod::Spec.new do |s|


s.name         = "xyfBaseFramework"
s.version      = "1.0.22"
s.summary      = "xyf基本框架"

s.homepage     = "https://github.com/xialun/xyfBaseFramework.git"

s.license= { :type => "MIT", :file => "LICENSE" }

s.author       = { "wangshuai" => "1032188750@qq.com" }




s.source       = { :git => "https://github.com/xialun/xyfBaseFramework.git", :tag => "1.0.22" }


s.source_files  = "xyfBaseFramework/**/*.{h,m}"

s.requires_arc = true

s.public_header_files  = "xyfBaseFramework/System/SCBaseObserveDefine.h"
git
s.platform     = :ios, "7.0"




s.dependency 'AFNetworking', '~> 3.1.0'
s.dependency 'FMDB', '~> 2.7.2'
s.dependency 'RSA', '~> 1.0.0'




end