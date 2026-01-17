import '../../../../core/domain/entity.dart';

/// Booking status enum matching database
enum BookingStatus {
  pending,
  accepted,
  rejected,
  inProgress,
  completed,
  cancelled;
  
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending Approval';
      case BookingStatus.accepted:
        return 'Accepted';
      case BookingStatus.rejected:
        return 'Rejected';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Rate unit for pricing
enum RateUnit {
  hourly,
  daily,
  fixed;
  
  String get displayName {
    switch (this) {
      case RateUnit.hourly:
        return 'per hour';
      case RateUnit.daily:
        return 'per day';
      case RateUnit.fixed:
        return 'fixed';
    }
  }
}

/// Booking entity representing complete booking lifecycle
class Booking extends Entity {
  final String id;
  
  // Parties
  final String farmerId;
  final String farmerName;
  final String providerId;
  final String providerName;
  
  // Service (either equipment or labour)
  final String? equipmentId;
  final String? labourId;
  final String serviceTitle;
  
  // Location
  final double jobLatitude;
  final double jobLongitude;
  final String jobAddress;
  
  // Scheduling
  final DateTime requestedStartDate;
  final DateTime? requestedEndDate;
  final DateTime? actualStartTime;
  final DateTime? actualEndTime;
  
  // Pricing
  final double agreedRate;
  final RateUnit rateUnit;
  final double? totalAmount;
  
  // Status
  final BookingStatus status;
  final String? rejectionReason;
  final String? cancellationReason;
  
  // Notes
  final String? specialInstructions;
  
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Booking({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.providerId,
    required this.providerName,
    this.equipmentId,
    this.labourId,
    required this.serviceTitle,
    required this.jobLatitude,
    required this.jobLongitude,
    required this.jobAddress,
    required this.requestedStartDate,
    this.requestedEndDate,
    this.actualStartTime,
    this.actualEndTime,
    required this.agreedRate,
    required this.rateUnit,
    this.totalAmount,
    this.status = BookingStatus.pending,
    this.rejectionReason,
    this.cancellationReason,
    this.specialInstructions,
    required this.createdAt,
    required this.updatedAt,
  });
  
  /// Check if booking is equipment type
  bool get isEquipmentBooking => equipmentId != null;
  
  /// Check if booking is labour type
  bool get isLabourBooking => labourId != null;
  
  // Status checks
  bool get isPending => status == BookingStatus.pending;
  bool get isAccepted => status == BookingStatus.accepted;
  bool get isRejected => status == BookingStatus.rejected;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;
  
  /// Check if booking can be started
  bool get canStart => status == BookingStatus.accepted;
  
  /// Check if booking can be completed
  bool get canComplete => status == BookingStatus.inProgress;
  
  /// Check if booking can be cancelled
  bool get canCancel => 
    status == BookingStatus.pending || 
    status == BookingStatus.accepted;
  
  /// Calculate actual duration if job is completed
  Duration? get actualDuration {
    if (actualStartTime != null && actualEndTime != null) {
      return actualEndTime!.difference(actualStartTime!);
    }
    return null;
  }
  
  /// Format rate for display
  String get formattedRate => '₹${agreedRate.toStringAsFixed(0)} ${rateUnit.displayName}';
  
  /// Format total amount for display
  String get formattedTotal => 
    totalAmount != null ? '₹${totalAmount!.toStringAsFixed(0)}' : 'TBD';
  
  /// Copy with method
  Booking copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? providerId,
    String? providerName,
    String? equipmentId,
    String? labourId,
    String? serviceTitle,
    double? jobLatitude,
    double? jobLongitude,
    String? jobAddress,
    DateTime? requestedStartDate,
    DateTime? requestedEndDate,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    double? agreedRate,
    RateUnit? rateUnit,
    double? totalAmount,
    BookingStatus? status,
    String? rejectionReason,
    String? cancellationReason,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      equipmentId: equipmentId ?? this.equipmentId,
      labourId: labourId ?? this.labourId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      jobLatitude: jobLatitude ?? this.jobLatitude,
      jobLongitude: jobLongitude ?? this.jobLongitude,
      jobAddress: jobAddress ?? this.jobAddress,
      requestedStartDate: requestedStartDate ?? this.requestedStartDate,
      requestedEndDate: requestedEndDate ?? this.requestedEndDate,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      agreedRate: agreedRate ?? this.agreedRate,
      rateUnit: rateUnit ?? this.rateUnit,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id,
    farmerId,
    farmerName,
    providerId,
    providerName,
    equipmentId,
    labourId,
    serviceTitle,
    jobLatitude,
    jobLongitude,
    jobAddress,
    requestedStartDate,
    requestedEndDate,
    actualStartTime,
    actualEndTime,
    agreedRate,
    rateUnit,
    totalAmount,
    status,
    rejectionReason,
    cancellationReason,
    specialInstructions,
    createdAt,
    updatedAt,
  ];
}
