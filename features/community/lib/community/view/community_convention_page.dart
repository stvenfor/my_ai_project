import 'package:flutter/material.dart';
import 'package:module_common_ui/module_common_ui.dart';

/// 完整社区公约详情页（弹窗「点击了解完整社区公约」入口）。
class CommunityConventionPage extends StatelessWidget {
  const CommunityConventionPage({super.key});

  static const _titleColor = Color(0xFF1A1A1A);
  static const _bodyColor = Color(0xFF333333);

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      navBar: const AppNavBar(title: '社区公约', showBackButton: true),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: const [
          Text(
            '盘友圈社区公约',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _titleColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '更新日期：2026-09-22',
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          SizedBox(height: 20),
          _P(
            '亲爱的用户，您好：\n\n'
            '欢迎来到支付宝理财社区-盘友圈。我们希望打造一个友善、有趣、有料的理财社区，'
            '请在发布内容、评论互动前仔细阅读并遵守本公约。',
          ),
          SizedBox(height: 20),
          _H('一、尊重他人'),
          _P(
            '请勿发布侵犯他人合法权益的内容，包括但不限于侮辱、诽谤、骚扰、人肉搜索、'
            '泄露他人隐私等恶意行为；请以善意、理性的方式参与讨论。',
          ),
          SizedBox(height: 16),
          _H('二、尊重事实'),
          _P(
            '请勿编造或传播虚假信息、不良价值观；请勿发布未经证实的投资建议或恐吓性言论；'
            '请勿发布营销广告、软文推广，以及诱导关注、导流站外交易等行为。',
          ),
          SizedBox(height: 16),
          _H('三、尊重平台'),
          _P(
            '请勿发布违反法律法规、监管要求或金融法规的内容，包括但不限于欺诈、'
            '违规荐股、违规金融营销、赌博、色情、暴力等；请勿干扰社区正常秩序或滥用产品功能。',
          ),
          SizedBox(height: 16),
          _H('四、内容与互动'),
          _P(
            '发布的图文、视频、评论应与理财社区氛围相符；禁止刷屏、恶意引战、'
            '滥用「问大家」等能力。平台有权对违规内容采取删除、限流、禁言等措施。',
          ),
          SizedBox(height: 16),
          _H('五、免责说明'),
          _P(
            '社区内容仅供交流参考，不构成任何投资建议。用户应独立判断并自行承担风险。'
            '因用户违规造成的损失，由用户自行承担责任。',
          ),
          SizedBox(height: 24),
          _P(
            '一个友善温暖的理财社区，需要大家一起来守护。感谢您的理解与支持～',
          ),
        ],
      ),
    );
  }
}

class _H extends StatelessWidget {
  const _H(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: CommunityConventionPage._titleColor,
          height: 1.4,
        ),
      ),
    );
  }
}

class _P extends StatelessWidget {
  const _P(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.7,
        color: CommunityConventionPage._bodyColor,
      ),
    );
  }
}
