import 'package:flutter/material.dart';
import 'package:reqres_flutter/detail.dart';
import 'package:reqres_flutter/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  late Future<List<User>> _futureUsers;

  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers();
  }

  Future<List<User>> getUsers() async {
    final response1 = await http.get(Uri.parse('https://reqres.in/api/users?page=1'));
    final response2 = await http.get(Uri.parse('https://reqres.in/api/users?page=2'));
    if (response1.statusCode == 200 && response2.statusCode == 200) {
      final List<dynamic> data1 = jsonDecode(response1.body)['data'];
      final List<dynamic> data2 = jsonDecode(response2.body)['data'];
      final List<dynamic> combinedData = [...data1, ...data2];
      return combinedData.map((userJson) => User.fromJson(userJson)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('User List')),
      body: FutureBuilder<List<User>>(
        future: _futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(snapshot.data![index].avatar),
                  ),
                  title: Text('${snapshot.data![index].firstName} ${snapshot.data![index].lastName}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailPage(userId: snapshot.data![index].id),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
