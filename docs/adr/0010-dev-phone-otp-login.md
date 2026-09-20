# 开放开发环境手机号 OTP 登录（测试号）

Go BFF 在非 release 下对测试号 `13400000000` + OTP `123456` 提供 `phone/otp/send` 与 `verify`，返回与邮箱登录相同的 Auth Session。生产/非测试号仍返回「短信登录暂未开放」。Flutter `BackendAuthService` 已对接；主缝测试覆盖 verify 写会话与 InvalidOtp。真实短信通道不在本决策范围。
