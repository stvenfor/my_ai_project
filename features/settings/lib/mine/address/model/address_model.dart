class AddressModel {
  const AddressModel({
    required this.addressId,
    required this.receiverName,
    required this.receiverPhone,
    required this.province,
    required this.city,
    required this.district,
    required this.detailAddress,
    required this.fullAddress,
    required this.isDefault,
    this.postalCode = '',
    this.label = '',
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      addressId: (json['address_id'] as num?)?.toInt() ?? 0,
      receiverName: json['receiver_name']?.toString() ?? '',
      receiverPhone: json['receiver_phone']?.toString() ?? '',
      province: json['province']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      detailAddress: json['detail_address']?.toString() ?? '',
      postalCode: json['postal_code']?.toString() ?? '',
      isDefault: json['is_default'] == true,
      label: json['label']?.toString() ?? '',
      fullAddress: json['full_address']?.toString() ?? '',
    );
  }

  final int addressId;
  final String receiverName;
  final String receiverPhone;
  final String province;
  final String city;
  final String district;
  final String detailAddress;
  final String postalCode;
  final bool isDefault;
  final String label;
  final String fullAddress;

  Map<String, dynamic> toBridgeJson() => {
        'address_id': addressId,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'province': province,
        'city': city,
        'district': district,
        'detail_address': detailAddress,
        'full_address': fullAddress,
        'is_default': isDefault,
        'label': label,
      };
}
