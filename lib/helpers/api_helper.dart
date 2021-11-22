import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:huellitas_app_flutter/helpers/constants.dart';
import 'package:huellitas_app_flutter/models/document_type.dart';
import 'package:huellitas_app_flutter/models/response.dart';
import 'package:huellitas_app_flutter/models/token.dart';
import 'package:huellitas_app_flutter/models/user.dart';

class ApiHelper {
  static Future<Response> getUsers(Token token) async {
    if (!_validToken(token)) {
      return Response(isSuccess: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    
    var url = Uri.parse('${Constants.apiUrl}/api/Users');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<User> list = [];    
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(User.fromJson(item));
      }
    }

    return Response(isSuccess: true, result: list);
  }
  
  static Future<Response> getUser(Token token, String id) async {
    if (!_validToken(token)) {
      return Response(isSuccess: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    
    var url = Uri.parse('${Constants.apiUrl}/api/Users/$id');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
        'authorization': 'bearer ${token.token}',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    var decodedJson = jsonDecode(body);
    return Response(isSuccess: true, result: User.fromJson(decodedJson));
  }

  static Future<Response> getDocumentTypes() async {
    var url = Uri.parse('${Constants.apiUrl}/api/DocumentTypes');
    var response = await http.get(
      url,
      headers: {
        'content-type' : 'application/json',
        'accept' : 'application/json',
      },
    );

    var body = response.body;
    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: body);
    }

    List<DocumentType> list = [];    
    var decodedJson = jsonDecode(body);
    if (decodedJson != null) {
      for (var item in decodedJson) {
        list.add(DocumentType.fromJson(item));
      }
    }

    return Response(isSuccess: true, result: list);
  }

  static Future<Response> post(String controller, Map<String, dynamic> request, Token token) async {
    if (!_validToken(token)) {
      return Response(isSuccess: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    
    var url = Uri.parse('${Constants.apiUrl}$controller');
    var response = await http.post(
      url,
      headers: {
        'content-Type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}'
      },
      body: jsonEncode(request)
    );

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }
  
  static Future<Response> put(String controller, String id, Map<String, dynamic> request, Token token) async {
    if (!_validToken(token)) {
      return Response(isSuccess: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    
    var url = Uri.parse('${Constants.apiUrl}$controller$id');
    var response = await http.put(
      url,
      headers: {
        'content-Type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}'
      },
      body: jsonEncode(request)
    );

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }
  
  static Future<Response> delete(String controller, String id, Token token) async {
    if (!_validToken(token)) {
      return Response(isSuccess: false, message: 'Sus credenciales se han vencido, por favor cierre sesión y vuelva a ingresar al sistema.');
    }
    
    var url = Uri.parse('${Constants.apiUrl}$controller$id');
    var response = await http.delete(
      url,
      headers: {
        'content-Type': 'application/json',
        'accept': 'application/json',
        'authorization': 'bearer ${token.token}'
      }
    );

    if (response.statusCode >= 400) {
      return Response(isSuccess: false, message: response.body);
    }

    return Response(isSuccess: true);
  }
  
  static bool _validToken(Token token) {
    if (DateTime.parse(token.expiration).isAfter(DateTime.now())) {
      return true;
    }
    return false;
  }
}