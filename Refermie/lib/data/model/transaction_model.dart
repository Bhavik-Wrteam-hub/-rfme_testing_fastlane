class TransactionModel {
  TransactionModel({
    this.id,
    this.transactionId,
    this.amount,
    this.paymentGateway,
    this.packageId,
    this.customerId,
    this.paymentStatus,
    this.createdAt,
    this.updatedAt,
    this.paymentType,
    this.orderId,
    this.package,
    this.rejectReason,
  });

  TransactionModel.fromMap(Map<String, dynamic> json) {
    id = json['id'] as int?;
    transactionId = json['transaction_id']?.toString() ?? '';
    amount = json['amount'];
    paymentGateway = json['payment_gateway']?.toString() ?? '';
    paymentType = json['payment_type']?.toString() ?? '';
    packageId = int.parse(json['package_id']?.toString() ?? '');
    customerId = int.parse(json['user_id']?.toString() ?? '');
    paymentStatus = json['payment_status'];
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    orderId = json['order_id']?.toString() ?? '';
    rejectReason = json['reject_reason']?.toString() ?? '';
    package = json['package'] != null
        ? PackageModel.fromMap(json['package'] as Map<String, dynamic>? ?? {})
        : null;
  }
  int? id;
  String? transactionId;
  dynamic amount;
  String? paymentGateway;
  int? packageId;
  int? customerId;
  dynamic paymentStatus;
  String? paymentType;
  String? createdAt;
  String? updatedAt;
  String? orderId;
  String? rejectReason;
  PackageModel? package;
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['amount'] = amount;
    data['payment_gateway'] = paymentGateway;
    data['package_id'] = packageId;
    data['customer_id'] = customerId;
    data['payment_status'] = paymentStatus;
    data['payment_type'] = paymentType;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['order_id'] = orderId;
    if (package != null) {
      data['package'] = package!.toMap();
    }
    return data;
  }
}

class PackageModel {
  PackageModel({
    this.id,
    this.name,
    this.price,
  });
  PackageModel.fromMap(Map<String, dynamic> json) {
    id = json['id'] as int;
    name = json['name']?.toString() ?? '';
    price = json['price']?.toString() ?? '';
  }
  int? id;
  String? name;
  String? price;
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['price'] = price;
    return data;
  }
}
