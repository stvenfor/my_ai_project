//
//  Generated code. Do not modify.
//  source: analytics/v1/analytics.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'analytics.pb.dart' as $0;

export 'analytics.pb.dart';

@$pb.GrpcServiceName('analytics.v1.AnalyticsService')
class AnalyticsServiceClient extends $grpc.Client {
  static final _$listAnalyticsRecords = $grpc.ClientMethod<$0.ListAnalyticsRecordsRequest, $0.ListAnalyticsRecordsResponse>(
      '/analytics.v1.AnalyticsService/ListAnalyticsRecords',
      ($0.ListAnalyticsRecordsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListAnalyticsRecordsResponse.fromBuffer(value));
  static final _$getAnalyticsRecord = $grpc.ClientMethod<$0.GetAnalyticsRecordRequest, $0.GetAnalyticsRecordResponse>(
      '/analytics.v1.AnalyticsService/GetAnalyticsRecord',
      ($0.GetAnalyticsRecordRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetAnalyticsRecordResponse.fromBuffer(value));

  AnalyticsServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.ListAnalyticsRecordsResponse> listAnalyticsRecords($0.ListAnalyticsRecordsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listAnalyticsRecords, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetAnalyticsRecordResponse> getAnalyticsRecord($0.GetAnalyticsRecordRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getAnalyticsRecord, request, options: options);
  }
}

@$pb.GrpcServiceName('analytics.v1.AnalyticsService')
abstract class AnalyticsServiceBase extends $grpc.Service {
  $core.String get $name => 'analytics.v1.AnalyticsService';

  AnalyticsServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ListAnalyticsRecordsRequest, $0.ListAnalyticsRecordsResponse>(
        'ListAnalyticsRecords',
        listAnalyticsRecords_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListAnalyticsRecordsRequest.fromBuffer(value),
        ($0.ListAnalyticsRecordsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetAnalyticsRecordRequest, $0.GetAnalyticsRecordResponse>(
        'GetAnalyticsRecord',
        getAnalyticsRecord_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetAnalyticsRecordRequest.fromBuffer(value),
        ($0.GetAnalyticsRecordResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.ListAnalyticsRecordsResponse> listAnalyticsRecords_Pre($grpc.ServiceCall call, $async.Future<$0.ListAnalyticsRecordsRequest> request) async {
    return listAnalyticsRecords(call, await request);
  }

  $async.Future<$0.GetAnalyticsRecordResponse> getAnalyticsRecord_Pre($grpc.ServiceCall call, $async.Future<$0.GetAnalyticsRecordRequest> request) async {
    return getAnalyticsRecord(call, await request);
  }

  $async.Future<$0.ListAnalyticsRecordsResponse> listAnalyticsRecords($grpc.ServiceCall call, $0.ListAnalyticsRecordsRequest request);
  $async.Future<$0.GetAnalyticsRecordResponse> getAnalyticsRecord($grpc.ServiceCall call, $0.GetAnalyticsRecordRequest request);
}
