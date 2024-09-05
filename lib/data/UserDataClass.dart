class UserDataClass {
  String? imageUrl;
  String? uuid;
  String? age;
  String? sex;
  String? bodyType;

  UserDataClass({this.imageUrl, this.uuid, this.age, this.sex, this.bodyType});

  Map<String, dynamic> toJson() {
    return {
      'imageUrl': imageUrl,
      'uuid': uuid,
      'age': age,
      'sex': sex,
      'bodyType': bodyType,
    };
  }
}