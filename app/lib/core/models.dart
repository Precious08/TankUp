// TankUp domain models (mirrors supabase schema + docs/api/contract.md).

enum Fuel { petrol, cng, ev }

Fuel? fuelFrom(String s) {
  switch (s) {
    case 'Petrol':
      return Fuel.petrol;
    case 'CNG':
      return Fuel.cng;
    case 'EV':
      return Fuel.ev;
    default:
      return null;
  }
}

String fuelName(Fuel f) => switch (f) {
      Fuel.petrol => 'Petrol',
      Fuel.cng => 'CNG',
      Fuel.ev => 'EV',
    };

class Station {
  final String id;
  final String name;
  final String state;
  final String lga;
  final String area;
  final String address;
  final double lng;
  final double lat;
  final List<Fuel> fuels;
  final double price;
  final String unit;
  final bool open;
  final String availability;
  final String hours;
  final double rating;
  final int reviews;

  const Station({
    required this.id,
    required this.name,
    required this.state,
    required this.lga,
    required this.area,
    required this.address,
    required this.lng,
    required this.lat,
    required this.fuels,
    required this.price,
    required this.unit,
    required this.open,
    required this.availability,
    required this.hours,
    required this.rating,
    required this.reviews,
  });

  String get priceLabel => '₦${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}$unit';
}

class Vehicle {
  final String nickname;
  final Fuel energy;
  final bool active;
  const Vehicle({required this.nickname, required this.energy, this.active = false});

  Vehicle copyWith({String? nickname, Fuel? energy, bool? active}) => Vehicle(
        nickname: nickname ?? this.nickname,
        energy: energy ?? this.energy,
        active: active ?? this.active,
      );
}
