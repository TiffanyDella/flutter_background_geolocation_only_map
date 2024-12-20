///
/// NOTE:  There's nothing particularly interesting in this class for BackgroundGeolocation.
/// This is just a bootstrap app for selecting app to run (Hello World App, Advanced App).
///
/// Go look at the source for those apps instead.
///

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:url_launcher/url_launcher.dart';

import 'config/ENV.dart';
import 'config/transistor_auth.dart';

import 'registration_view.dart';
import 'advanced/app.dart';
import 'package:flutter_background_geolocation_example/advanced/util/dialog.dart'
    as util;

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => new _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return new MaterialApp(
        theme: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(secondary:Colors.black)),
        home: new _HomeView());
  }
}

class _HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => new _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  static const USERNAME_REGEXP = r"^[a-zA-Z0-9_-]*$";

  late bg.DeviceInfo _deviceInfo;
  late String _orgname;
  late String _username;
  late String _deviceId;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    _orgname = '';
    _username = '';
    _deviceId = '';
    _initPlatformState();
  }

  void _initPlatformState() async {
    // Rendering Home page, stop everything and remove all listeners.
    bg.BackgroundGeolocation.stop();
    await bg.BackgroundGeolocation.removeListeners();
    TransistorAuth.registerErrorHandler();

    _deviceInfo = await bg.DeviceInfo.getInstance();

    // Reset selected app.
    final SharedPreferences prefs = await _prefs;
    prefs.setString("app", "");

    // Set username.
    String? username = prefs.getString("username");
    String? orgname = prefs.getString("orgname");

    if (_usernameIsValid(username!) && (orgname == null)) {
      await prefs.remove('username');
      await prefs.setString('orgname', username);
      orgname = username;
      username = null;
    }

    setState(() {
      _orgname = (orgname != null) ? orgname : '';
      _username = (username != null) ? username : '';
      _deviceId = (username != null)
          ? "${_deviceInfo.model}-$_username"
          : _deviceInfo.model;
    });

    if (!_usernameIsValid(username!) || !_usernameIsValid(orgname!)) {
      _showRegistration();
    }
  }

  void _showRegistration() async {
    

    final result = await Navigator.of(context).push(MaterialPageRoute<Map>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return RegistrationView();
        }));

    if (result != null) {
      setState(() {
        _orgname = result["orgname"];
        _username = result["username"];
        _deviceId = "${_deviceInfo.model}-${result["username"]}";
      });
    }
  }

  void _onClickNavigate(String appName) async {
   if (!_usernameIsValid(_username) || !_usernameIsValid(_orgname)) {
  _showRegistration();
  return;
}

final SharedPreferences prefs = await _prefs;
bool hasDisclosedBackgroundPermission =
    prefs.containsKey("has_disclosed_background_permission");

// Удаляем код, который отображает AlertDialog

if (defaultTargetPlatform == TargetPlatform.android) {
  prefs.setBool("has_disclosed_background_permission", true);
}

prefs.setString("app", appName);

Widget app;
switch (appName) {
  case AdvancedApp.NAME:
    app = new AdvancedApp();
    break;
  default:
    return;
}

runApp(app);

  }

  bool _usernameIsValid(String username) {
    return (username != null) &&
        new RegExp(USERNAME_REGEXP).hasMatch(username) &&
        (username.length > 0);
  }

  void _launchUrl() async {
    String url = '${ENV.TRACKER_HOST}/$_orgname';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Background Geolocation'),
          foregroundColor: Colors.black,
          backgroundColor: Colors.amberAccent
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
            color: Colors.black87,
            padding: EdgeInsets.only(top: 20.0),
            child: Column(
                
                children: <Widget>[
                  
                  Expanded(
                      child: Container(
                          
                          child: Column(
                              
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                               
                                _buildApplicationButton('Open Map',
                                    onPressed: () {
                                  _onClickNavigate("advanced");
                                }),
                                SizedBox(height: 20.0),
                                _buildApplicationButton('Regist',
                                    onPressed: () {
                                  _showRegistration();
                                }),
                                SizedBox(height: 20.0),
                                Text("Device ID: $_deviceId", style: TextStyle(color: Colors.white),),
                                Text("Organization: $_orgname", style: TextStyle(color: Colors.white),),
                              ]))),
                  Container(
                      
                      child: Column(
                          
                          children: <Widget>[
                            Text(
                                "fork created by: TiffanyDella. Original Author: Transistorsoft", style: TextStyle(color: Colors.white),),
                            
                          ]))
                ]))
);
  }

  MaterialButton _buildApplicationButton(String text, {onPressed=Function}) {
    return MaterialButton(
        onPressed: onPressed,
        child: Text(text, style: TextStyle(fontSize: 18.0)),
        color: Colors.amber,
        height: 50.0);
  }
}

