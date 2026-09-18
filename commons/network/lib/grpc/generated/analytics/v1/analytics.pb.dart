//
//  Generated code. Do not modify.
//  source: analytics/v1/analytics.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ListAnalyticsRecordsRequest extends $pb.GeneratedMessage {
  factory ListAnalyticsRecordsRequest({
    $core.int? page,
    $core.int? pageSize,
  }) {
    final $result = create();
    if (page != null) {
      $result.page = page;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    return $result;
  }
  ListAnalyticsRecordsRequest._() : super();
  factory ListAnalyticsRecordsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAnalyticsRecordsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAnalyticsRecordsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'analytics.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'page', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAnalyticsRecordsRequest clone() => ListAnalyticsRecordsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAnalyticsRecordsRequest copyWith(void Function(ListAnalyticsRecordsRequest) updates) => super.copyWith((message) => updates(message as ListAnalyticsRecordsRequest)) as ListAnalyticsRecordsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAnalyticsRecordsRequest create() => ListAnalyticsRecordsRequest._();
  ListAnalyticsRecordsRequest createEmptyInstance() => create();
  static $pb.PbList<ListAnalyticsRecordsRequest> createRepeated() => $pb.PbList<ListAnalyticsRecordsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListAnalyticsRecordsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAnalyticsRecordsRequest>(create);
  static ListAnalyticsRecordsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get page => $_getIZ(0);
  @$pb.TagNumber(1)
  set page($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPage() => $_has(0);
  @$pb.TagNumber(1)
  void clearPage() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => clearField(2);
}

class ListAnalyticsRecordsResponse extends $pb.GeneratedMessage {
  factory ListAnalyticsRecordsResponse({
    $core.Iterable<AnalyticsRecord>? items,
    $fixnum.Int64? total,
    $core.int? page,
    $core.int? pageSize,
  }) {
    final $result = create();
    if (items != null) {
      $result.items.addAll(items);
    }
    if (total != null) {
      $result.total = total;
    }
    if (page != null) {
      $result.page = page;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    return $result;
  }
  ListAnalyticsRecordsResponse._() : super();
  factory ListAnalyticsRecordsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAnalyticsRecordsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAnalyticsRecordsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'analytics.v1'), createEmptyInstance: create)
    ..pc<AnalyticsRecord>(1, _omitFieldNames ? '' : 'items', $pb.PbFieldType.PM, subBuilder: AnalyticsRecord.create)
    ..aInt64(2, _omitFieldNames ? '' : 'total')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'page', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAnalyticsRecordsResponse clone() => ListAnalyticsRecordsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAnalyticsRecordsResponse copyWith(void Function(ListAnalyticsRecordsResponse) updates) => super.copyWith((message) => updates(message as ListAnalyticsRecordsResponse)) as ListAnalyticsRecordsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAnalyticsRecordsResponse create() => ListAnalyticsRecordsResponse._();
  ListAnalyticsRecordsResponse createEmptyInstance() => create();
  static $pb.PbList<ListAnalyticsRecordsResponse> createRepeated() => $pb.PbList<ListAnalyticsRecordsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAnalyticsRecordsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAnalyticsRecordsResponse>(create);
  static ListAnalyticsRecordsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AnalyticsRecord> get items => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get total => $_getI64(1);
  @$pb.TagNumber(2)
  set total($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get page => $_getIZ(2);
  @$pb.TagNumber(3)
  set page($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPage() => $_has(2);
  @$pb.TagNumber(3)
  void clearPage() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get pageSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set pageSize($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPageSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearPageSize() => clearField(4);
}

class GetAnalyticsRecordRequest extends $pb.GeneratedMessage {
  factory GetAnalyticsRecordRequest({
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  GetAnalyticsRecordRequest._() : super();
  factory GetAnalyticsRecordRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAnalyticsRecordRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAnalyticsRecordRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'analytics.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAnalyticsRecordRequest clone() => GetAnalyticsRecordRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAnalyticsRecordRequest copyWith(void Function(GetAnalyticsRecordRequest) updates) => super.copyWith((message) => updates(message as GetAnalyticsRecordRequest)) as GetAnalyticsRecordRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAnalyticsRecordRequest create() => GetAnalyticsRecordRequest._();
  GetAnalyticsRecordRequest createEmptyInstance() => create();
  static $pb.PbList<GetAnalyticsRecordRequest> createRepeated() => $pb.PbList<GetAnalyticsRecordRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAnalyticsRecordRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAnalyticsRecordRequest>(create);
  static GetAnalyticsRecordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetAnalyticsRecordResponse extends $pb.GeneratedMessage {
  factory GetAnalyticsRecordResponse({
    AnalyticsRecord? item,
  }) {
    final $result = create();
    if (item != null) {
      $result.item = item;
    }
    return $result;
  }
  GetAnalyticsRecordResponse._() : super();
  factory GetAnalyticsRecordResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAnalyticsRecordResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAnalyticsRecordResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'analytics.v1'), createEmptyInstance: create)
    ..aOM<AnalyticsRecord>(1, _omitFieldNames ? '' : 'item', subBuilder: AnalyticsRecord.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAnalyticsRecordResponse clone() => GetAnalyticsRecordResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAnalyticsRecordResponse copyWith(void Function(GetAnalyticsRecordResponse) updates) => super.copyWith((message) => updates(message as GetAnalyticsRecordResponse)) as GetAnalyticsRecordResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAnalyticsRecordResponse create() => GetAnalyticsRecordResponse._();
  GetAnalyticsRecordResponse createEmptyInstance() => create();
  static $pb.PbList<GetAnalyticsRecordResponse> createRepeated() => $pb.PbList<GetAnalyticsRecordResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAnalyticsRecordResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAnalyticsRecordResponse>(create);
  static GetAnalyticsRecordResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AnalyticsRecord get item => $_getN(0);
  @$pb.TagNumber(1)
  set item(AnalyticsRecord v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => clearField(1);
  @$pb.TagNumber(1)
  AnalyticsRecord ensureItem() => $_ensure(0);
}

/// AnalyticsRecord 与表 analytics_records 对齐；时间为 Unix 秒。
class AnalyticsRecord extends $pb.GeneratedMessage {
  factory AnalyticsRecord({
    $fixnum.Int64? id,
    $core.String? code,
    $core.String? title,
    $core.String? subtitle,
    $core.String? category,
    $core.String? subCategory,
    $core.String? status,
    $core.int? priority,
    $core.String? region,
    $core.String? channel,
    $core.String? ownerName,
    $core.String? ownerTeam,
    $core.String? sourceSystem,
    $fixnum.Int64? metricPv,
    $fixnum.Int64? metricUv,
    $fixnum.Int64? metricClick,
    $fixnum.Int64? metricConvert,
    $core.double? metricRevenue,
    $core.double? metricCost,
    $core.double? metricRoi,
    $core.double? metricBounceRate,
    $core.int? metricAvgDurationSec,
    $core.double? scoreQuality,
    $core.double? scoreRisk,
    $core.String? tagPrimary,
    $core.String? tagSecondary,
    $core.bool? flagFeatured,
    $core.bool? flagAnomaly,
    $core.String? notes,
    $fixnum.Int64? observedAt,
    $fixnum.Int64? windowStart,
    $fixnum.Int64? windowEnd,
    $fixnum.Int64? publishedAt,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (code != null) {
      $result.code = code;
    }
    if (title != null) {
      $result.title = title;
    }
    if (subtitle != null) {
      $result.subtitle = subtitle;
    }
    if (category != null) {
      $result.category = category;
    }
    if (subCategory != null) {
      $result.subCategory = subCategory;
    }
    if (status != null) {
      $result.status = status;
    }
    if (priority != null) {
      $result.priority = priority;
    }
    if (region != null) {
      $result.region = region;
    }
    if (channel != null) {
      $result.channel = channel;
    }
    if (ownerName != null) {
      $result.ownerName = ownerName;
    }
    if (ownerTeam != null) {
      $result.ownerTeam = ownerTeam;
    }
    if (sourceSystem != null) {
      $result.sourceSystem = sourceSystem;
    }
    if (metricPv != null) {
      $result.metricPv = metricPv;
    }
    if (metricUv != null) {
      $result.metricUv = metricUv;
    }
    if (metricClick != null) {
      $result.metricClick = metricClick;
    }
    if (metricConvert != null) {
      $result.metricConvert = metricConvert;
    }
    if (metricRevenue != null) {
      $result.metricRevenue = metricRevenue;
    }
    if (metricCost != null) {
      $result.metricCost = metricCost;
    }
    if (metricRoi != null) {
      $result.metricRoi = metricRoi;
    }
    if (metricBounceRate != null) {
      $result.metricBounceRate = metricBounceRate;
    }
    if (metricAvgDurationSec != null) {
      $result.metricAvgDurationSec = metricAvgDurationSec;
    }
    if (scoreQuality != null) {
      $result.scoreQuality = scoreQuality;
    }
    if (scoreRisk != null) {
      $result.scoreRisk = scoreRisk;
    }
    if (tagPrimary != null) {
      $result.tagPrimary = tagPrimary;
    }
    if (tagSecondary != null) {
      $result.tagSecondary = tagSecondary;
    }
    if (flagFeatured != null) {
      $result.flagFeatured = flagFeatured;
    }
    if (flagAnomaly != null) {
      $result.flagAnomaly = flagAnomaly;
    }
    if (notes != null) {
      $result.notes = notes;
    }
    if (observedAt != null) {
      $result.observedAt = observedAt;
    }
    if (windowStart != null) {
      $result.windowStart = windowStart;
    }
    if (windowEnd != null) {
      $result.windowEnd = windowEnd;
    }
    if (publishedAt != null) {
      $result.publishedAt = publishedAt;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    return $result;
  }
  AnalyticsRecord._() : super();
  factory AnalyticsRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyticsRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyticsRecord', package: const $pb.PackageName(_omitMessageNames ? '' : 'analytics.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'code')
    ..aOS(3, _omitFieldNames ? '' : 'title')
    ..aOS(4, _omitFieldNames ? '' : 'subtitle')
    ..aOS(5, _omitFieldNames ? '' : 'category')
    ..aOS(6, _omitFieldNames ? '' : 'subCategory')
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'region')
    ..aOS(10, _omitFieldNames ? '' : 'channel')
    ..aOS(11, _omitFieldNames ? '' : 'ownerName')
    ..aOS(12, _omitFieldNames ? '' : 'ownerTeam')
    ..aOS(13, _omitFieldNames ? '' : 'sourceSystem')
    ..aInt64(14, _omitFieldNames ? '' : 'metricPv')
    ..aInt64(15, _omitFieldNames ? '' : 'metricUv')
    ..aInt64(16, _omitFieldNames ? '' : 'metricClick')
    ..aInt64(17, _omitFieldNames ? '' : 'metricConvert')
    ..a<$core.double>(18, _omitFieldNames ? '' : 'metricRevenue', $pb.PbFieldType.OD)
    ..a<$core.double>(19, _omitFieldNames ? '' : 'metricCost', $pb.PbFieldType.OD)
    ..a<$core.double>(20, _omitFieldNames ? '' : 'metricRoi', $pb.PbFieldType.OD)
    ..a<$core.double>(21, _omitFieldNames ? '' : 'metricBounceRate', $pb.PbFieldType.OD)
    ..a<$core.int>(22, _omitFieldNames ? '' : 'metricAvgDurationSec', $pb.PbFieldType.O3)
    ..a<$core.double>(23, _omitFieldNames ? '' : 'scoreQuality', $pb.PbFieldType.OD)
    ..a<$core.double>(24, _omitFieldNames ? '' : 'scoreRisk', $pb.PbFieldType.OD)
    ..aOS(25, _omitFieldNames ? '' : 'tagPrimary')
    ..aOS(26, _omitFieldNames ? '' : 'tagSecondary')
    ..aOB(27, _omitFieldNames ? '' : 'flagFeatured')
    ..aOB(28, _omitFieldNames ? '' : 'flagAnomaly')
    ..aOS(29, _omitFieldNames ? '' : 'notes')
    ..aInt64(30, _omitFieldNames ? '' : 'observedAt')
    ..aInt64(31, _omitFieldNames ? '' : 'windowStart')
    ..aInt64(32, _omitFieldNames ? '' : 'windowEnd')
    ..aInt64(33, _omitFieldNames ? '' : 'publishedAt')
    ..aInt64(34, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(35, _omitFieldNames ? '' : 'updatedAt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyticsRecord clone() => AnalyticsRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyticsRecord copyWith(void Function(AnalyticsRecord) updates) => super.copyWith((message) => updates(message as AnalyticsRecord)) as AnalyticsRecord;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyticsRecord create() => AnalyticsRecord._();
  AnalyticsRecord createEmptyInstance() => create();
  static $pb.PbList<AnalyticsRecord> createRepeated() => $pb.PbList<AnalyticsRecord>();
  @$core.pragma('dart2js:noInline')
  static AnalyticsRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyticsRecord>(create);
  static AnalyticsRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get code => $_getSZ(1);
  @$pb.TagNumber(2)
  set code($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearCode() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get title => $_getSZ(2);
  @$pb.TagNumber(3)
  set title($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTitle() => $_has(2);
  @$pb.TagNumber(3)
  void clearTitle() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get subtitle => $_getSZ(3);
  @$pb.TagNumber(4)
  set subtitle($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSubtitle() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubtitle() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get category => $_getSZ(4);
  @$pb.TagNumber(5)
  set category($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCategory() => $_has(4);
  @$pb.TagNumber(5)
  void clearCategory() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get subCategory => $_getSZ(5);
  @$pb.TagNumber(6)
  set subCategory($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSubCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearSubCategory() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get priority => $_getIZ(7);
  @$pb.TagNumber(8)
  set priority($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPriority() => $_has(7);
  @$pb.TagNumber(8)
  void clearPriority() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get region => $_getSZ(8);
  @$pb.TagNumber(9)
  set region($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasRegion() => $_has(8);
  @$pb.TagNumber(9)
  void clearRegion() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get channel => $_getSZ(9);
  @$pb.TagNumber(10)
  set channel($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasChannel() => $_has(9);
  @$pb.TagNumber(10)
  void clearChannel() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get ownerName => $_getSZ(10);
  @$pb.TagNumber(11)
  set ownerName($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasOwnerName() => $_has(10);
  @$pb.TagNumber(11)
  void clearOwnerName() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get ownerTeam => $_getSZ(11);
  @$pb.TagNumber(12)
  set ownerTeam($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasOwnerTeam() => $_has(11);
  @$pb.TagNumber(12)
  void clearOwnerTeam() => clearField(12);

  @$pb.TagNumber(13)
  $core.String get sourceSystem => $_getSZ(12);
  @$pb.TagNumber(13)
  set sourceSystem($core.String v) { $_setString(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasSourceSystem() => $_has(12);
  @$pb.TagNumber(13)
  void clearSourceSystem() => clearField(13);

  @$pb.TagNumber(14)
  $fixnum.Int64 get metricPv => $_getI64(13);
  @$pb.TagNumber(14)
  set metricPv($fixnum.Int64 v) { $_setInt64(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasMetricPv() => $_has(13);
  @$pb.TagNumber(14)
  void clearMetricPv() => clearField(14);

  @$pb.TagNumber(15)
  $fixnum.Int64 get metricUv => $_getI64(14);
  @$pb.TagNumber(15)
  set metricUv($fixnum.Int64 v) { $_setInt64(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasMetricUv() => $_has(14);
  @$pb.TagNumber(15)
  void clearMetricUv() => clearField(15);

  @$pb.TagNumber(16)
  $fixnum.Int64 get metricClick => $_getI64(15);
  @$pb.TagNumber(16)
  set metricClick($fixnum.Int64 v) { $_setInt64(15, v); }
  @$pb.TagNumber(16)
  $core.bool hasMetricClick() => $_has(15);
  @$pb.TagNumber(16)
  void clearMetricClick() => clearField(16);

  @$pb.TagNumber(17)
  $fixnum.Int64 get metricConvert => $_getI64(16);
  @$pb.TagNumber(17)
  set metricConvert($fixnum.Int64 v) { $_setInt64(16, v); }
  @$pb.TagNumber(17)
  $core.bool hasMetricConvert() => $_has(16);
  @$pb.TagNumber(17)
  void clearMetricConvert() => clearField(17);

  @$pb.TagNumber(18)
  $core.double get metricRevenue => $_getN(17);
  @$pb.TagNumber(18)
  set metricRevenue($core.double v) { $_setDouble(17, v); }
  @$pb.TagNumber(18)
  $core.bool hasMetricRevenue() => $_has(17);
  @$pb.TagNumber(18)
  void clearMetricRevenue() => clearField(18);

  @$pb.TagNumber(19)
  $core.double get metricCost => $_getN(18);
  @$pb.TagNumber(19)
  set metricCost($core.double v) { $_setDouble(18, v); }
  @$pb.TagNumber(19)
  $core.bool hasMetricCost() => $_has(18);
  @$pb.TagNumber(19)
  void clearMetricCost() => clearField(19);

  @$pb.TagNumber(20)
  $core.double get metricRoi => $_getN(19);
  @$pb.TagNumber(20)
  set metricRoi($core.double v) { $_setDouble(19, v); }
  @$pb.TagNumber(20)
  $core.bool hasMetricRoi() => $_has(19);
  @$pb.TagNumber(20)
  void clearMetricRoi() => clearField(20);

  @$pb.TagNumber(21)
  $core.double get metricBounceRate => $_getN(20);
  @$pb.TagNumber(21)
  set metricBounceRate($core.double v) { $_setDouble(20, v); }
  @$pb.TagNumber(21)
  $core.bool hasMetricBounceRate() => $_has(20);
  @$pb.TagNumber(21)
  void clearMetricBounceRate() => clearField(21);

  @$pb.TagNumber(22)
  $core.int get metricAvgDurationSec => $_getIZ(21);
  @$pb.TagNumber(22)
  set metricAvgDurationSec($core.int v) { $_setSignedInt32(21, v); }
  @$pb.TagNumber(22)
  $core.bool hasMetricAvgDurationSec() => $_has(21);
  @$pb.TagNumber(22)
  void clearMetricAvgDurationSec() => clearField(22);

  @$pb.TagNumber(23)
  $core.double get scoreQuality => $_getN(22);
  @$pb.TagNumber(23)
  set scoreQuality($core.double v) { $_setDouble(22, v); }
  @$pb.TagNumber(23)
  $core.bool hasScoreQuality() => $_has(22);
  @$pb.TagNumber(23)
  void clearScoreQuality() => clearField(23);

  @$pb.TagNumber(24)
  $core.double get scoreRisk => $_getN(23);
  @$pb.TagNumber(24)
  set scoreRisk($core.double v) { $_setDouble(23, v); }
  @$pb.TagNumber(24)
  $core.bool hasScoreRisk() => $_has(23);
  @$pb.TagNumber(24)
  void clearScoreRisk() => clearField(24);

  @$pb.TagNumber(25)
  $core.String get tagPrimary => $_getSZ(24);
  @$pb.TagNumber(25)
  set tagPrimary($core.String v) { $_setString(24, v); }
  @$pb.TagNumber(25)
  $core.bool hasTagPrimary() => $_has(24);
  @$pb.TagNumber(25)
  void clearTagPrimary() => clearField(25);

  @$pb.TagNumber(26)
  $core.String get tagSecondary => $_getSZ(25);
  @$pb.TagNumber(26)
  set tagSecondary($core.String v) { $_setString(25, v); }
  @$pb.TagNumber(26)
  $core.bool hasTagSecondary() => $_has(25);
  @$pb.TagNumber(26)
  void clearTagSecondary() => clearField(26);

  @$pb.TagNumber(27)
  $core.bool get flagFeatured => $_getBF(26);
  @$pb.TagNumber(27)
  set flagFeatured($core.bool v) { $_setBool(26, v); }
  @$pb.TagNumber(27)
  $core.bool hasFlagFeatured() => $_has(26);
  @$pb.TagNumber(27)
  void clearFlagFeatured() => clearField(27);

  @$pb.TagNumber(28)
  $core.bool get flagAnomaly => $_getBF(27);
  @$pb.TagNumber(28)
  set flagAnomaly($core.bool v) { $_setBool(27, v); }
  @$pb.TagNumber(28)
  $core.bool hasFlagAnomaly() => $_has(27);
  @$pb.TagNumber(28)
  void clearFlagAnomaly() => clearField(28);

  @$pb.TagNumber(29)
  $core.String get notes => $_getSZ(28);
  @$pb.TagNumber(29)
  set notes($core.String v) { $_setString(28, v); }
  @$pb.TagNumber(29)
  $core.bool hasNotes() => $_has(28);
  @$pb.TagNumber(29)
  void clearNotes() => clearField(29);

  @$pb.TagNumber(30)
  $fixnum.Int64 get observedAt => $_getI64(29);
  @$pb.TagNumber(30)
  set observedAt($fixnum.Int64 v) { $_setInt64(29, v); }
  @$pb.TagNumber(30)
  $core.bool hasObservedAt() => $_has(29);
  @$pb.TagNumber(30)
  void clearObservedAt() => clearField(30);

  @$pb.TagNumber(31)
  $fixnum.Int64 get windowStart => $_getI64(30);
  @$pb.TagNumber(31)
  set windowStart($fixnum.Int64 v) { $_setInt64(30, v); }
  @$pb.TagNumber(31)
  $core.bool hasWindowStart() => $_has(30);
  @$pb.TagNumber(31)
  void clearWindowStart() => clearField(31);

  @$pb.TagNumber(32)
  $fixnum.Int64 get windowEnd => $_getI64(31);
  @$pb.TagNumber(32)
  set windowEnd($fixnum.Int64 v) { $_setInt64(31, v); }
  @$pb.TagNumber(32)
  $core.bool hasWindowEnd() => $_has(31);
  @$pb.TagNumber(32)
  void clearWindowEnd() => clearField(32);

  @$pb.TagNumber(33)
  $fixnum.Int64 get publishedAt => $_getI64(32);
  @$pb.TagNumber(33)
  set publishedAt($fixnum.Int64 v) { $_setInt64(32, v); }
  @$pb.TagNumber(33)
  $core.bool hasPublishedAt() => $_has(32);
  @$pb.TagNumber(33)
  void clearPublishedAt() => clearField(33);

  @$pb.TagNumber(34)
  $fixnum.Int64 get createdAt => $_getI64(33);
  @$pb.TagNumber(34)
  set createdAt($fixnum.Int64 v) { $_setInt64(33, v); }
  @$pb.TagNumber(34)
  $core.bool hasCreatedAt() => $_has(33);
  @$pb.TagNumber(34)
  void clearCreatedAt() => clearField(34);

  @$pb.TagNumber(35)
  $fixnum.Int64 get updatedAt => $_getI64(34);
  @$pb.TagNumber(35)
  set updatedAt($fixnum.Int64 v) { $_setInt64(34, v); }
  @$pb.TagNumber(35)
  $core.bool hasUpdatedAt() => $_has(34);
  @$pb.TagNumber(35)
  void clearUpdatedAt() => clearField(35);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
