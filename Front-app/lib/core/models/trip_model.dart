class TripDriver {
  final String name;
  final String carModel;
  final String plate;
  final double rating;
  final int trips;
  final String? photoUrl;

  TripDriver({
    required this.name,
    required this.carModel,
    required this.plate,
    required this.rating,
    required this.trips,
    this.photoUrl,
  });

  factory TripDriver.fromJson(Map<String, dynamic> json) {
    return TripDriver(
      name: json['name'] as String? ?? json['username'] as String? ?? 'Motorista',
      carModel: json['car_model'] as String? ?? json['vehicle_model'] as String? ?? '',
      plate: json['plate'] as String? ?? json['license_plate'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      trips: (json['trips'] as num?)?.toInt() ?? (json['total_trips'] as num?)?.toInt() ?? 0,
      photoUrl: json['photo_url'] as String? ?? json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'carModel': carModel,
    'plate': plate,
    'rating': rating,
    'trips': trips,
    'photoUrl': photoUrl ?? 'https://i.pravatar.cc/150?img=11',
    'etaMins': 3,
  };
}

class Trip {
  final int id;
  final String origin;
  final String destination;
  final double price;
  final String status;
  final TripDriver? driver;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.price,
    required this.status,
    this.driver,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    TripDriver? driver;
    final driverData = json['driver_info'] ?? json['driver'];
    if (driverData is Map<String, dynamic>) {
      driver = TripDriver.fromJson(driverData);
    }

    return Trip(
      id: (json['id'] as num).toInt(),
      origin: json['origin'] as String? ?? '',
      destination: json['destination'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      driver: driver,
    );
  }

  bool get isPending => status == 'pending' || status == 'requested';
  bool get isAccepted => status == 'accepted';
  bool get isInProgress => status == 'in_progress' || status == 'started';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled' || status == 'canceled';
}
