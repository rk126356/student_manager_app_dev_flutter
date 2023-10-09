class UserModel {
  String? name;
  String? email;
  String? avatarUrl;
  String? uid;
  Students? students;
  Batches? batches;

  UserModel(
      {this.name,
      this.email,
      this.uid,
      this.students,
      this.batches,
      this.avatarUrl});

  UserModel.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    avatarUrl = json['avatarUrl'];
    uid = json['uid'];
    students = json['students'] != null
        ? new Students.fromJson(json['students'])
        : null;
    batches =
        json['batches'] != null ? new Batches.fromJson(json['batches']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['email'] = this.email;
    data['avatarUrl'] = this.avatarUrl;
    data['uid'] = this.uid;
    if (this.students != null) {
      data['students'] = this.students!.toJson();
    }
    if (this.batches != null) {
      data['batches'] = this.batches!.toJson();
    }
    return data;
  }
}

class Students {
  String? studentName;
  String? studentBatch;
  String? joinedDate;
  String? lastPaidDate;
  bool? isActive;
  bool? isLeft;
  bool? isUnpaid;
  bool? isPaid;

  Students(
      {this.studentName,
      this.studentBatch,
      this.joinedDate,
      this.lastPaidDate,
      this.isActive,
      this.isLeft,
      this.isUnpaid,
      this.isPaid});

  Students.fromJson(Map<String, dynamic> json) {
    studentName = json['studentName'];
    studentBatch = json['studentBatch'];
    joinedDate = json['JoinedDate'];
    lastPaidDate = json['lastPaidDate'];
    isActive = json['isActive'];
    isLeft = json['isLeft'];
    isUnpaid = json['isUnpaid'];
    isPaid = json['isPaid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['studentName'] = this.studentName;
    data['studentBatch'] = this.studentBatch;
    data['JoinedDate'] = this.joinedDate;
    data['lastPaidDate'] = this.lastPaidDate;
    data['isActive'] = this.isActive;
    data['isLeft'] = this.isLeft;
    data['isUnpaid'] = this.isUnpaid;
    data['isPaid'] = this.isPaid;
    return data;
  }
}

class Batches {
  String? batchName;
  String? createdDate;
  bool? isOpen;
  bool? isClosed;

  Batches({this.batchName, this.createdDate, this.isOpen, this.isClosed});

  Batches.fromJson(Map<String, dynamic> json) {
    batchName = json['batchName'];
    createdDate = json['createdDate'];
    isOpen = json['isOpen'];
    isClosed = json['isClosed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['batchName'] = this.batchName;
    data['createdDate'] = this.createdDate;
    data['isOpen'] = this.isOpen;
    data['isClosed'] = this.isClosed;
    return data;
  }
}
