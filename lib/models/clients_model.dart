class ClientModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  ClientModel.freomJson(Map<String, dynamic> data) {
    id = data['id'];
    name = data['name'];
    email = data['email'];
    phone = data['phone'];
    address = data['address'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }
}
