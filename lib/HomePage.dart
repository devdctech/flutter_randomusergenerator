import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseURL = 'https://randomuser.me/api/?results=';
  List userData;
  bool isLoading = true;
  var message;
  int indexSelected = -1;
  final inputController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setInput();
    });
  }

  void setInput() {
    inputController.text = "";
    isLoading = true;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            hintText: 'How Many entries you want?'),
                        controller: inputController),
                    SizedBox(
                      width: 320.0,
                      child: RaisedButton(
                        onPressed: () {
                          getData(baseURL + inputController.text);
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: const Color(0xFF1BC0C5),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Future getData(String url) async {
    var response = await http
        .get(Uri.encodeFull(url), headers: {'Accept': 'applications/json'});
    List data = jsonDecode(response.body)['results'];
    setState(() {
      userData = data;
      isLoading = false;
      message = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Users'),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: () => setInput())
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 50.0),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator()
                : CarouselSlider.builder(
                    options: CarouselOptions(
                      enableInfiniteScroll: false,
                      aspectRatio: 3 / 3,
                      scrollDirection: Axis.horizontal,
                    ),
                    itemCount: userData == null ? 0 : userData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(20.0),
                              width: 150.0,
                              height: 150.0,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(
                                        userData[index]['picture']['large']),
                                  )),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: Text(
                                userData[index]['name']['first'] +
                                    ' ' +
                                    userData[index]['name']['last'],
                                style: TextStyle(
                                  fontSize: 25.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15.0),
                              child: Text(
                                this.message,
                                style: TextStyle(
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: ChoiceChip(
                                    label: Icon(Icons.person),
                                    selected: indexSelected == 0,
                                    onSelected: (value) {
                                      setState(() {
                                        indexSelected = value ? 0 : -1;
                                        message = userData[index]['login']
                                            ['username'];
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Icon(Icons.email),
                                    selected: indexSelected == 1,
                                    onSelected: (value) {
                                      setState(() {
                                        indexSelected = value ? 1 : -1;
                                        message = userData[index]['email'];
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Icon(Icons.location_on),
                                    selected: indexSelected == 2,
                                    onSelected: (value) {
                                      setState(() {
                                        indexSelected = value ? 2 : -1;
                                        message = userData[index]['location']
                                                ['city'] +
                                            ' ' +
                                            userData[index]['location']
                                                ['state'];
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: ChoiceChip(
                                    label: Icon(Icons.phone),
                                    selected: indexSelected == 3,
                                    onSelected: (value) {
                                      setState(() {
                                        indexSelected = value ? 3 : -1;
                                        message = userData[index]['phone'];
                                      });
                                    },
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
