class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;
  String? currency;

  UserModel({this.name, this.email, this.uid, this.avatarUrl, this.currency});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatarUrl'] = this.avatarUrl;
    data['uid'] = this.uid;
    data['currency'] = this.currency;

    return data;
  }
}
