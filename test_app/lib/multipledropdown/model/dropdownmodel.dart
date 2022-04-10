
class StateModel {
  List<States>? states;

  StateModel({this.states});

  StateModel.fromJson(Map<String, dynamic> json) {
    if (json['states'] != null) {
      states = <States>[];
      json['states'].forEach((v) {
        states!.add( States.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (states != null) {
      data['states'] = states!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class States {
  String? statename;
  String? id;
  List<Cities>? cities;

  States({this.statename, this.id, this.cities});

  States.fromJson(Map<String, dynamic> json) {
    statename = json['statename'];
    id = json['id'];
    if (json['cities'] != null) {
      cities = <Cities>[];
      json['cities'].forEach((v) {
        cities!.add(new Cities.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statename'] = this.statename;
    data['id'] = this.id;
    if (this.cities != null) {
      data['cities'] = this.cities!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cities {
  String? name;
  String? id;
  List<Areas>? areas;

  Cities({this.name, this.id, this.areas});

  Cities.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    if (json['areas'] != null) {
      areas = <Areas>[];
      json['areas'].forEach((v) {
        areas!.add(new Areas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    if (this.areas != null) {
      data['areas'] = this.areas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Areas {
  String? name;
  String? id;
  List<Pincode>? pincode;

  Areas({this.name, this.id, this.pincode});

  Areas.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    id = json['id'];
    if (json['pincode'] != null) {
      pincode = <Pincode>[];
      json['pincode'].forEach((v) {
        pincode!.add(new Pincode.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['id'] = this.id;
    if (this.pincode != null) {
      data['pincode'] = this.pincode!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Pincode {
  String? pc;
  String? pincode;

  Pincode({this.pc, this.pincode});

  Pincode.fromJson(Map<String, dynamic> json) {
    pc = json['pc'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pc'] = this.pc;
    data['pincode'] = this.pincode;
    return data;
  }
}
