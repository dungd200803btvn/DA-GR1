class VoucherAppliedInfo {
  final String type;
  final num discountValue;
  final List<String>? appliedDetails;
  VoucherAppliedInfo({
    required this.type,
    required this.discountValue,
    this.appliedDetails
  });
}
