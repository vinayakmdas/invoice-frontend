import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:invoice/features/user/data/model/invoice_data_model.dart';
import 'package:invoice/features/user/data/model/item_data_model.dart';

class UserApiDatasource {
  static const String _base = 'https://invoice-backend-17pz.onrender.com/api/';

  // ── Items ──────────────────────────────────────────────────────────────────

  Future<List<ItemDataModel>> fetchItems() async {
    final res = await http.get(Uri.parse('$_base/items/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => ItemDataModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch items: ${res.statusCode}');
  }

  Future<ItemDataModel> createItem(ItemDataModel item) async {
    final res = await http.post(
      Uri.parse('$_base/add-item/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return ItemDataModel.fromJson(jsonDecode(res.body));
    }
    // Surface field-level errors from Django
    final body = jsonDecode(res.body);
    throw Exception(_extractError(body));
  }

  // ── Invoices ───────────────────────────────────────────────────────────────

  Future<List<InvoiceDataModel>> fetchInvoices() async {
    final res = await http.get(Uri.parse('$_base/invoices/'));
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => InvoiceDataModel.fromJson(e)).toList();
    }
    throw Exception('Failed to fetch invoices: ${res.statusCode}');
  }

  Future<InvoiceDataModel> createInvoice(InvoiceDataModel invoice) async {
    final res = await http.post(
      Uri.parse('$_base/add-invoice/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(invoice.toJson()),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return InvoiceDataModel.fromJson(jsonDecode(res.body));
    }
    final body = jsonDecode(res.body);
    throw Exception(_extractError(body));
  }

  Future<void> deleteInvoice(int id) async {
    final res = await http.delete(Uri.parse('$_base/delete-invoice/$id/'));
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete invoice: ${res.statusCode}');
    }
  }

  String _extractError(dynamic body) {
    if (body is Map) {
      final msgs = <String>[];
      body.forEach((key, value) {
        if (value is List)
          msgs.addAll(value.map((e) => e.toString()));
        else
          msgs.add(value.toString());
      });
      return msgs.join('\n');
    }
    return body.toString();
  }
}
