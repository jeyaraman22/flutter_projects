import 'dart:convert';

class productModel {
  String? name ;
  String? price;
  String? image;
  String? description;
  String? quantity;
  String? date;
  String? createdby;
  String? orderby;
  String? orderID;
  String? orderTime;

  productModel(
      {required this.name,
      required this.price,
      required this.image,
      required this.description,
      required this.quantity,
      required this.createdby,
      required this.orderID,
      required this.orderTime,
      required this.orderby,
      required this.date});

  productModel.fromJson(Map<String,dynamic> json) {
    name = json['name'];
    price = json['price'];
    image = json['image'];
    description = json['desc'];
    quantity = json['quantity'];
    createdby = json['createdby'];
    orderID = json['orderID'];
    orderTime = json['orderTime'];
    orderby = json['orderby'];
    date = json['date'];
  }
}

class orderModel{
  String? orderId;
  String? orderDate;
  String? orderTime;
  String? orderby;
  String? totalAmount;
  List<product>? orderProducts;

  orderModel({required this.orderId,
              required this.orderDate,
              required this.orderTime,
              required this.totalAmount,
              required this.orderProducts,
              required this.orderby});

  orderModel.fromJson(Map<String,dynamic> json){
    orderDate = json['orderDate'];
    orderId = json['orderID'];
    orderTime = json['orderTime'];
    orderby = json['orderby'];
    totalAmount = json['totalAmount'];
    orderProducts = <product>[];
    json['products'].forEach((k,v){
      orderProducts!.add(product.fromJson(v));
    });
  }

}

class product{
  String? name;
  String? quantity;
  String? price;

  product({required this.name,required this.quantity,required this.price});

  product.fromJson(Map<String, dynamic> json){
   name = json['name'];
   quantity = json['quantity'];
   price = json['price'];
  }
}
