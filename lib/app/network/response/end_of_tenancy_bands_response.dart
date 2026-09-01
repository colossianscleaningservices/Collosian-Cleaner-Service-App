class EndOfTenancyBandsResponse {
  EndOfTenancyBandsResponse({
    this.message,
    this.version,
    this.code,
    this.data,
  });

  EndOfTenancyBandsResponse.fromJson(dynamic json) {
    message = json['message'];
    version = json['version'];
    code = json['code'];
    data = json['data'] != null ? EndOfTenancyBandsData.fromJson(json['data']) : null;
  }

  String? message;
  String? version;
  num? code;
  EndOfTenancyBandsData? data;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['message'] = message;
    map['version'] = version;
    map['code'] = code;
    if (data != null) {
      map['data'] = data?.toJson();
    }
    return map;
  }
}

class EndOfTenancyBandsData {
  EndOfTenancyBandsData({
    this.suggestedBandId,
    this.bands,
  });

  EndOfTenancyBandsData.fromJson(dynamic json) {
    suggestedBandId = json['suggested_band_id'];
    if (json['bands'] != null) {
      bands = [];
      json['bands'].forEach((v) {
        bands?.add(EndOfTenancyBand.fromJson(v));
      });
    }
  }

  num? suggestedBandId;
  List<EndOfTenancyBand>? bands;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['suggested_band_id'] = suggestedBandId;
    if (bands != null) {
      map['bands'] = bands?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EndOfTenancyBand {
  EndOfTenancyBand({
    this.id,
    this.name,
    this.slug,
    this.matchKind,
    this.matchBedrooms,
    this.staffCountMode,
    this.staffCountValue,
    this.sortOrder,
    this.matchLabel,
    this.addOns,
  });

  EndOfTenancyBand.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    slug = json['slug'];
    matchKind = json['match_kind'];
    matchBedrooms = json['match_bedrooms'];
    staffCountMode = json['staff_count_mode'];
    staffCountValue = json['staff_count_value'];
    sortOrder = json['sort_order'];
    matchLabel = json['match_label'];
    if (json['add_ons'] != null) {
      addOns = [];
      json['add_ons'].forEach((v) {
        addOns?.add(EndOfTenancyAddOn.fromJson(v));
      });
    }
  }

  num? id;
  String? name;
  String? slug;
  String? matchKind;
  num? matchBedrooms;
  String? staffCountMode;
  num? staffCountValue;
  num? sortOrder;
  String? matchLabel;
  List<EndOfTenancyAddOn>? addOns;

  String get displayLabel {
    final n = (name ?? '').trim();
    final m = (matchLabel ?? '').trim();
    if (n.isEmpty) return m;
    if (m.isEmpty || m.toLowerCase() == n.toLowerCase()) return n;
    return '$n ($m)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EndOfTenancyBand && id != null && other.id == id;
  }

  @override
  int get hashCode => id?.hashCode ?? identityHashCode(this);

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['slug'] = slug;
    map['match_kind'] = matchKind;
    map['match_bedrooms'] = matchBedrooms;
    map['staff_count_mode'] = staffCountMode;
    map['staff_count_value'] = staffCountValue;
    map['sort_order'] = sortOrder;
    map['match_label'] = matchLabel;
    if (addOns != null) {
      map['add_ons'] = addOns?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class EndOfTenancyAddOn {
  EndOfTenancyAddOn({
    this.id,
    this.name,
    this.label,
    this.title,
    this.description,
    this.note,
    this.quantity,
    this.price,
    this.unitPrice,
    this.amount,
    this.awaitingPrice,
  });

  EndOfTenancyAddOn.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    label = json['label'];
    title = json['title'];
    description = json['description'];
    note = json['note'];
    quantity = json['quantity'];
    price = json['price'];
    unitPrice = json['unit_price'];
    amount = json['amount'];
    awaitingPrice = json['awaiting_price'];
  }

  num? id;
  String? name;
  String? label;
  String? title;
  String? description;
  String? note;
  num? quantity;
  dynamic price;
  dynamic unitPrice;
  dynamic amount;
  bool? awaitingPrice;

  String get displayName {
    final value = (name ?? label ?? title ?? '').trim();
    return value.isEmpty ? 'Extra' : value;
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['label'] = label;
    map['title'] = title;
    map['description'] = description;
    map['note'] = note;
    map['quantity'] = quantity;
    map['price'] = price;
    map['unit_price'] = unitPrice;
    map['amount'] = amount;
    map['awaiting_price'] = awaitingPrice;
    return map;
  }
}

class EndOfTenancyCustomAddOn {
  EndOfTenancyCustomAddOn({
    this.id,
    this.label,
    this.note,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.awaitingPrice,
  });

  EndOfTenancyCustomAddOn.fromJson(dynamic json) {
    id = json['id'];
    label = json['label'];
    note = json['note'];
    quantity = json['quantity'];
    unitPrice = json['unit_price'];
    amount = json['amount'];
    awaitingPrice = json['awaiting_price'];
  }

  num? id;
  String? label;
  String? note;
  num? quantity;
  dynamic unitPrice;
  dynamic amount;
  bool? awaitingPrice;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'note': note,
      'quantity': quantity,
      'unit_price': unitPrice,
      'amount': amount,
      'awaiting_price': awaitingPrice,
    };
  }
}
