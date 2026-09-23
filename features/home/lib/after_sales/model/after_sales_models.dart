/// 售后专区模型。
class AfterSalesRecord {
  const AfterSalesRecord({
    required this.recordId,
    required this.storeId,
    required this.customerName,
    required this.customerPhone,
    required this.serviceKind,
    required this.serviceKindLabel,
    required this.title,
    required this.content,
    required this.serviceDate,
    this.appointmentId,
    this.plateNo = '',
    this.mileage,
  });

  final int recordId;
  final int storeId;
  final int? appointmentId;
  final String customerName;
  final String customerPhone;
  final int serviceKind;
  final String serviceKindLabel;
  final String title;
  final String content;
  final String serviceDate;
  final String plateNo;
  final int? mileage;

  factory AfterSalesRecord.fromJson(Map<String, dynamic> json) {
    return AfterSalesRecord(
      recordId: _int(json['record_id']),
      storeId: _int(json['store_id']),
      appointmentId: json['appointment_id'] == null
          ? null
          : _int(json['appointment_id']),
      customerName: (json['customer_name'] as String?) ?? '',
      customerPhone: (json['customer_phone'] as String?) ?? '',
      serviceKind: _int(json['service_kind']),
      serviceKindLabel: (json['service_kind_label'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      serviceDate: (json['service_date'] as String?) ?? '',
      plateNo: (json['plate_no'] as String?) ?? '',
      mileage: json['mileage'] == null ? null : _int(json['mileage']),
    );
  }
}

class AfterSalesAppointment {
  const AfterSalesAppointment({
    required this.appointmentId,
    required this.customerName,
    required this.appointmentDate,
  });

  final int appointmentId;
  final String customerName;
  final String appointmentDate;

  factory AfterSalesAppointment.fromJson(Map<String, dynamic> json) {
    final dateRaw = json['appointment_date'];
    final date = dateRaw is String
        ? dateRaw.split('T').first
        : '$dateRaw';
    return AfterSalesAppointment(
      appointmentId: _int(json['appointment_id']),
      customerName: (json['customer_name'] as String?) ?? '',
      appointmentDate: date,
    );
  }
}

class AfterSalesListResult {
  const AfterSalesListResult({
    required this.list,
    required this.hasMore,
    required this.canCreate,
  });

  final List<AfterSalesRecord> list;
  final bool hasMore;
  final bool canCreate;
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse('$v') ?? 0;
}
