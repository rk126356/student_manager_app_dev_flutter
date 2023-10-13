class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;

  UserModel({this.name, this.email, this.uid, this.avatarUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatarUrl'] = this.avatarUrl;
    data['uid'] = this.uid;

    return data;
  }
}
