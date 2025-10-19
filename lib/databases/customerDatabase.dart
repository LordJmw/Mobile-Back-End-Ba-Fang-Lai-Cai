import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:projek_uts_mbr/helper/base_url.dart';
import 'package:projek_uts_mbr/model/CustomerModel.dart';

class Customerdatabase {
  

  Future<bool> updateCustomer(CustomerModel customer) async {
    final response = await http.put(
      Uri.parse('${base_url.customer}/update/${customer.id}'),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode(customer.toJson()),
    );
    return response.statusCode == 200;
  }
  
}