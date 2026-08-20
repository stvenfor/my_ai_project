import 'package:wys_network/wys_network.dart';

import '../models/account_user.dart';

abstract final class MockAccountSession {
  MockAccountSession._();

  static bool get enabled => WysMockManager.shouldMockUser;

  static const markerKey = '_mockSession';

  static const user = AccountUser(
    userId: '2606250024330515',
    token: 'mock_access_token_2606250024330515',
    nickname: '用户2606250024330515',
    avatarUrl: '',
    phone: '134338767667',
    extra: <String, dynamic>{
      markerKey: true,
      'account': '134338767667',
      'accountType': 'phone',
      'access_token': 'mock_access_token_2606250024330515',
      'refresh_token': 'mock_refresh_token_2606250024330515',
      'token_type': 'Bearer',
      'companyId': '2',
      'orgId': '',
      'platformOrgId': '',
      'platformCompanyId': '2',
      'platformCompanyName': 'T-FAMILY',
      'companyName': 'T-FAMILY',
      'memberId': '2606250024330515',
      'nickName': '用户2606250024330515',
      'headPortrait': '',
      'phone': '134338767667',
      'email': '',
      'openId': '',
      'userId': '2606250024330515',
      'userKind': 'member',
      'signature': '',
      'realName': '',
      'idCard': '',
      'idCardType': 1,
      'auth': 0,
      'authDesc': '未认证',
      'sex': 0,
      'passwordSet': 0,
      'star': 0,
      'pendantUrl': '',
      'serialNo': '2606250024330515',
      'serial': '2606250024330515',
      'isAbnormal': 0,
      'abnormalMsgV3': '',
      'authMsg': '',
      'isWeiXinBind': 0,
      'wxNickName': '',
      'roster': 0,
      'blackPayMsg': '',
      'rankId': 0,
      'rankTitle': '普通会员',
      'integral': 0,
      'growthValue': 0,
      'surplus': 0,
      'couponCount': 0,
      'memberSubjectVOS': <dynamic>[],
      'memberRankVOS': <dynamic>[],
    },
  );

  static bool isMock(AccountUser? user) =>
      user?.extra?[markerKey] == true ||
      user?.token == MockAccountSession.user.token;
}
