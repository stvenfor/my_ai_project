//
//  Generated code. Do not modify.
//  source: analytics/v1/analytics.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use listAnalyticsRecordsRequestDescriptor instead')
const ListAnalyticsRecordsRequest$json = {
  '1': 'ListAnalyticsRecordsRequest',
  '2': [
    {'1': 'page', '3': 1, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 2, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `ListAnalyticsRecordsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAnalyticsRecordsRequestDescriptor = $convert.base64Decode(
    'ChtMaXN0QW5hbHl0aWNzUmVjb3Jkc1JlcXVlc3QSEgoEcGFnZRgBIAEoBVIEcGFnZRIbCglwYW'
    'dlX3NpemUYAiABKAVSCHBhZ2VTaXpl');

@$core.Deprecated('Use listAnalyticsRecordsResponseDescriptor instead')
const ListAnalyticsRecordsResponse$json = {
  '1': 'ListAnalyticsRecordsResponse',
  '2': [
    {'1': 'items', '3': 1, '4': 3, '5': 11, '6': '.analytics.v1.AnalyticsRecord', '10': 'items'},
    {'1': 'total', '3': 2, '4': 1, '5': 3, '10': 'total'},
    {'1': 'page', '3': 3, '4': 1, '5': 5, '10': 'page'},
    {'1': 'page_size', '3': 4, '4': 1, '5': 5, '10': 'pageSize'},
  ],
};

/// Descriptor for `ListAnalyticsRecordsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listAnalyticsRecordsResponseDescriptor = $convert.base64Decode(
    'ChxMaXN0QW5hbHl0aWNzUmVjb3Jkc1Jlc3BvbnNlEjMKBWl0ZW1zGAEgAygLMh0uYW5hbHl0aW'
    'NzLnYxLkFuYWx5dGljc1JlY29yZFIFaXRlbXMSFAoFdG90YWwYAiABKANSBXRvdGFsEhIKBHBh'
    'Z2UYAyABKAVSBHBhZ2USGwoJcGFnZV9zaXplGAQgASgFUghwYWdlU2l6ZQ==');

@$core.Deprecated('Use getAnalyticsRecordRequestDescriptor instead')
const GetAnalyticsRecordRequest$json = {
  '1': 'GetAnalyticsRecordRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `GetAnalyticsRecordRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAnalyticsRecordRequestDescriptor = $convert.base64Decode(
    'ChlHZXRBbmFseXRpY3NSZWNvcmRSZXF1ZXN0Eg4KAmlkGAEgASgDUgJpZA==');

@$core.Deprecated('Use getAnalyticsRecordResponseDescriptor instead')
const GetAnalyticsRecordResponse$json = {
  '1': 'GetAnalyticsRecordResponse',
  '2': [
    {'1': 'item', '3': 1, '4': 1, '5': 11, '6': '.analytics.v1.AnalyticsRecord', '10': 'item'},
  ],
};

/// Descriptor for `GetAnalyticsRecordResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getAnalyticsRecordResponseDescriptor = $convert.base64Decode(
    'ChpHZXRBbmFseXRpY3NSZWNvcmRSZXNwb25zZRIxCgRpdGVtGAEgASgLMh0uYW5hbHl0aWNzLn'
    'YxLkFuYWx5dGljc1JlY29yZFIEaXRlbQ==');

@$core.Deprecated('Use analyticsRecordDescriptor instead')
const AnalyticsRecord$json = {
  '1': 'AnalyticsRecord',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'code', '3': 2, '4': 1, '5': 9, '10': 'code'},
    {'1': 'title', '3': 3, '4': 1, '5': 9, '10': 'title'},
    {'1': 'subtitle', '3': 4, '4': 1, '5': 9, '10': 'subtitle'},
    {'1': 'category', '3': 5, '4': 1, '5': 9, '10': 'category'},
    {'1': 'sub_category', '3': 6, '4': 1, '5': 9, '10': 'subCategory'},
    {'1': 'status', '3': 7, '4': 1, '5': 9, '10': 'status'},
    {'1': 'priority', '3': 8, '4': 1, '5': 5, '10': 'priority'},
    {'1': 'region', '3': 9, '4': 1, '5': 9, '10': 'region'},
    {'1': 'channel', '3': 10, '4': 1, '5': 9, '10': 'channel'},
    {'1': 'owner_name', '3': 11, '4': 1, '5': 9, '10': 'ownerName'},
    {'1': 'owner_team', '3': 12, '4': 1, '5': 9, '10': 'ownerTeam'},
    {'1': 'source_system', '3': 13, '4': 1, '5': 9, '10': 'sourceSystem'},
    {'1': 'metric_pv', '3': 14, '4': 1, '5': 3, '10': 'metricPv'},
    {'1': 'metric_uv', '3': 15, '4': 1, '5': 3, '10': 'metricUv'},
    {'1': 'metric_click', '3': 16, '4': 1, '5': 3, '10': 'metricClick'},
    {'1': 'metric_convert', '3': 17, '4': 1, '5': 3, '10': 'metricConvert'},
    {'1': 'metric_revenue', '3': 18, '4': 1, '5': 1, '10': 'metricRevenue'},
    {'1': 'metric_cost', '3': 19, '4': 1, '5': 1, '10': 'metricCost'},
    {'1': 'metric_roi', '3': 20, '4': 1, '5': 1, '10': 'metricRoi'},
    {'1': 'metric_bounce_rate', '3': 21, '4': 1, '5': 1, '10': 'metricBounceRate'},
    {'1': 'metric_avg_duration_sec', '3': 22, '4': 1, '5': 5, '10': 'metricAvgDurationSec'},
    {'1': 'score_quality', '3': 23, '4': 1, '5': 1, '10': 'scoreQuality'},
    {'1': 'score_risk', '3': 24, '4': 1, '5': 1, '10': 'scoreRisk'},
    {'1': 'tag_primary', '3': 25, '4': 1, '5': 9, '10': 'tagPrimary'},
    {'1': 'tag_secondary', '3': 26, '4': 1, '5': 9, '10': 'tagSecondary'},
    {'1': 'flag_featured', '3': 27, '4': 1, '5': 8, '10': 'flagFeatured'},
    {'1': 'flag_anomaly', '3': 28, '4': 1, '5': 8, '10': 'flagAnomaly'},
    {'1': 'notes', '3': 29, '4': 1, '5': 9, '10': 'notes'},
    {'1': 'observed_at', '3': 30, '4': 1, '5': 3, '10': 'observedAt'},
    {'1': 'window_start', '3': 31, '4': 1, '5': 3, '10': 'windowStart'},
    {'1': 'window_end', '3': 32, '4': 1, '5': 3, '10': 'windowEnd'},
    {'1': 'published_at', '3': 33, '4': 1, '5': 3, '10': 'publishedAt'},
    {'1': 'created_at', '3': 34, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 35, '4': 1, '5': 3, '10': 'updatedAt'},
  ],
};

/// Descriptor for `AnalyticsRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List analyticsRecordDescriptor = $convert.base64Decode(
    'Cg9BbmFseXRpY3NSZWNvcmQSDgoCaWQYASABKANSAmlkEhIKBGNvZGUYAiABKAlSBGNvZGUSFA'
    'oFdGl0bGUYAyABKAlSBXRpdGxlEhoKCHN1YnRpdGxlGAQgASgJUghzdWJ0aXRsZRIaCghjYXRl'
    'Z29yeRgFIAEoCVIIY2F0ZWdvcnkSIQoMc3ViX2NhdGVnb3J5GAYgASgJUgtzdWJDYXRlZ29yeR'
    'IWCgZzdGF0dXMYByABKAlSBnN0YXR1cxIaCghwcmlvcml0eRgIIAEoBVIIcHJpb3JpdHkSFgoG'
    'cmVnaW9uGAkgASgJUgZyZWdpb24SGAoHY2hhbm5lbBgKIAEoCVIHY2hhbm5lbBIdCgpvd25lcl'
    '9uYW1lGAsgASgJUglvd25lck5hbWUSHQoKb3duZXJfdGVhbRgMIAEoCVIJb3duZXJUZWFtEiMK'
    'DXNvdXJjZV9zeXN0ZW0YDSABKAlSDHNvdXJjZVN5c3RlbRIbCgltZXRyaWNfcHYYDiABKANSCG'
    '1ldHJpY1B2EhsKCW1ldHJpY191dhgPIAEoA1IIbWV0cmljVXYSIQoMbWV0cmljX2NsaWNrGBAg'
    'ASgDUgttZXRyaWNDbGljaxIlCg5tZXRyaWNfY29udmVydBgRIAEoA1INbWV0cmljQ29udmVydB'
    'IlCg5tZXRyaWNfcmV2ZW51ZRgSIAEoAVINbWV0cmljUmV2ZW51ZRIfCgttZXRyaWNfY29zdBgT'
    'IAEoAVIKbWV0cmljQ29zdBIdCgptZXRyaWNfcm9pGBQgASgBUgltZXRyaWNSb2kSLAoSbWV0cm'
    'ljX2JvdW5jZV9yYXRlGBUgASgBUhBtZXRyaWNCb3VuY2VSYXRlEjUKF21ldHJpY19hdmdfZHVy'
    'YXRpb25fc2VjGBYgASgFUhRtZXRyaWNBdmdEdXJhdGlvblNlYxIjCg1zY29yZV9xdWFsaXR5GB'
    'cgASgBUgxzY29yZVF1YWxpdHkSHQoKc2NvcmVfcmlzaxgYIAEoAVIJc2NvcmVSaXNrEh8KC3Rh'
    'Z19wcmltYXJ5GBkgASgJUgp0YWdQcmltYXJ5EiMKDXRhZ19zZWNvbmRhcnkYGiABKAlSDHRhZ1'
    'NlY29uZGFyeRIjCg1mbGFnX2ZlYXR1cmVkGBsgASgIUgxmbGFnRmVhdHVyZWQSIQoMZmxhZ19h'
    'bm9tYWx5GBwgASgIUgtmbGFnQW5vbWFseRIUCgVub3RlcxgdIAEoCVIFbm90ZXMSHwoLb2JzZX'
    'J2ZWRfYXQYHiABKANSCm9ic2VydmVkQXQSIQoMd2luZG93X3N0YXJ0GB8gASgDUgt3aW5kb3dT'
    'dGFydBIdCgp3aW5kb3dfZW5kGCAgASgDUgl3aW5kb3dFbmQSIQoMcHVibGlzaGVkX2F0GCEgAS'
    'gDUgtwdWJsaXNoZWRBdBIdCgpjcmVhdGVkX2F0GCIgASgDUgljcmVhdGVkQXQSHQoKdXBkYXRl'
    'ZF9hdBgjIAEoA1IJdXBkYXRlZEF0');

