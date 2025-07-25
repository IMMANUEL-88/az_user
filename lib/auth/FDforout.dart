// import 'dart:async';
//
// import 'package:attendzone_new/Api/Api.dart';
// import 'package:attendzone_new/helper_functions.dart';
// import 'package:facesdk_plugin/facedetection_interface.dart';
// import 'package:facesdk_plugin/facesdk_plugin.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../popups/fullscreen_loaders.dart';
// import '../screens/login.dart';
// import 'person.dart';
//
// bool reslut = false;
//
// @immutable
// class FaceRecognitionView extends StatefulWidget {
//   final List<Person> personList;
//   FaceDetectionViewController? faceDetectionViewController;
//
//   FaceRecognitionView({super.key, required this.personList});
//
//   @override
//   State<StatefulWidget> createState() => FaceRecognitionViewState();
// }
//
// class FaceRecognitionViewState extends State<FaceRecognitionView> {
//   dynamic _faces;
//   double _livenessThreshold = 0;
//   double _identifyThreshold = 0;
//   bool _recognized = false;
//
//   String _identifiedName = "";
//   String _identifiedSimilarity = "";
//   String _identifiedLiveness = "";
//   String _identifiedYaw = "";
//   String _identifiedRoll = "";
//   String _identifiedPitch = "";
//
//   var _identifiedFace;
//   var _enrolledFace;
//   final _facesdkPlugin = FacesdkPlugin();
//   FaceDetectionViewController? faceDetectionViewController;
//
//   @override
//   void initState() {
//     super.initState();
//
//     loadSettings();
//   }
//
//   Future<void> loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? livenessThreshold = prefs.getString("liveness_threshold");
//     String? identifyThreshold = prefs.getString("identify_threshold");
//     setState(() {
//       _livenessThreshold = double.parse(livenessThreshold ?? "0.7");
//       _identifyThreshold = double.parse(identifyThreshold ?? "0.8");
//     });
//   }
//
//   Future<void> faceRecognitionStart() async {
//     final prefs = await SharedPreferences.getInstance();
//     var cameraLens = prefs.getInt("camera_lens");
//
//     setState(() {
//       _faces = null;
//       _recognized = false;
//     });
//
//     await faceDetectionViewController?.startCamera(cameraLens ?? 1);
//   }
//
//   Future<bool> onFaceDetected(faces) async {
//     if (_recognized == true) {
//       return false;
//     }
//
//     if (!mounted) return false;
//
//     setState(() {
//       _faces = faces;
//     });
//
//     bool recognized = false;
//     double maxSimilarity = -1;
//     String maxSimilarityName = "";
//     double maxLiveness = -1;
//     double maxYaw = -1;
//     double maxRoll = -1;
//     double maxPitch = -1;
//     // ignore: prefer_typing_uninitialized_variables
//     var enrolledFace, identifedFace;
//     if (faces.length > 0) {
//       var face = faces[0];
//       for (var person in widget.personList) {
//         double similarity = await _facesdkPlugin.similarityCalculation(
//                 face['templates'], person.templates) ??
//             -1;
//         if (maxSimilarity < similarity) {
//           maxSimilarity = similarity;
//           maxSimilarityName = person.name;
//           maxLiveness = face['liveness'];
//           maxYaw = face['yaw'];
//           maxRoll = face['roll'];
//           maxPitch = face['pitch'];
//           identifedFace = face['faceJpg'];
//           enrolledFace = person.faceJpg;
//         }
//       }
//
//       if (maxSimilarity > _identifyThreshold &&
//           maxLiveness > _livenessThreshold) {
//         recognized = true;
//       }
//     }
//
//     Future.delayed(const Duration(milliseconds: 100), () async {
//       if (!mounted) return false;
//       setState(() {
//         _recognized = recognized;
//         _identifiedName = maxSimilarityName;
//         _identifiedSimilarity = maxSimilarity.toString();
//         _identifiedLiveness = maxLiveness.toString();
//         _identifiedYaw = maxYaw.toString();
//         _identifiedRoll = maxRoll.toString();
//         _identifiedPitch = maxPitch.toString();
//         _enrolledFace = enrolledFace;
//         _identifiedFace = identifedFace;
//       });
//       if (recognized) {
//         faceDetectionViewController?.stopCamera();
//         DateTime now = DateTime.now();
//         String year = now.year.toString().padLeft(2, '0');
//         String month = now.month.toString().padLeft(2, '0');
//         String day = now.day.toString().padLeft(2, '0');
//         String hour = now.hour.toString().padLeft(2, '0');
//         String minutes = now.minute.toString().padLeft(2, '0');
//         String seconds = now.second.toString().padLeft(2, '0');
//
//         String dateto = '$year-$month-$day';
//         String timeout = "$hour:$minutes:$seconds";
//         print('Date: $dateto, Timeout: $timeout');
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         var userId = prefs.getString('userid');
//         await Atten().updateTimeOut(userId!, dateto, timeout);
//
//         reslut = true;
//         if (reslut == true) {
//           EHelperFunctions.showSnackBar(context, "Check out at $timeout");
//         } else {
//           EHelperFunctions.showSnackBar(context, 'Authentication Failed');
//         }
//         EFullScreenLoader.openLoadingDialog('Loading...', context);
//         // Wait for 5 seconds before stopping the loader and navigating
//         Future.delayed(const Duration(seconds: 5), () {
//           EFullScreenLoader.stopLoading(context);
//           context.pushReplacement('/home');
//         });
//         setState(() {
//           _faces = null;
//         });
//       }
//       else{
//         Future.delayed(const Duration(seconds: 5), () {
//           EFullScreenLoader.stopLoading(context);
//           EHelperFunctions.showSnackBar(context, 'Marking Attendance Failed');});
//       }
//     });
//
//     return recognized;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         faceDetectionViewController?.stopCamera();
//         return true;
//       },
//       child: Scaffold(
//         body: Stack(
//           children: <Widget>[
//             FaceDetectionView(faceRecognitionViewState: this),
//             SizedBox(
//               width: double.infinity,
//               height: double.infinity,
//               child: CustomPaint(
//                 painter: FacePainter(
//                     faces: _faces, livenessThreshold: _livenessThreshold),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class FaceDetectionView extends StatefulWidget
//     implements FaceDetectionInterface {
//   FaceRecognitionViewState faceRecognitionViewState;
//
//   FaceDetectionView({super.key, required this.faceRecognitionViewState});
//
//   @override
//   Future<void> onFaceDetected(faces) async {
//     await faceRecognitionViewState.onFaceDetected(faces);
//   }
//
//   @override
//   State<StatefulWidget> createState() => _FaceDetectionViewState();
// }
//
// class _FaceDetectionViewState extends State<FaceDetectionView> {
//   @override
//   Widget build(BuildContext context) {
//     if (defaultTargetPlatform == TargetPlatform.android) {
//       return AndroidView(
//         viewType: 'facedetectionview',
//         onPlatformViewCreated: _onPlatformViewCreated,
//       );
//     } else {
//       return UiKitView(
//         viewType: 'facedetectionview',
//         onPlatformViewCreated: _onPlatformViewCreated,
//       );
//     }
//   }
//
//   void _onPlatformViewCreated(int id) async {
//     final prefs = await SharedPreferences.getInstance();
//     var cameraLens = prefs.getInt("camera_lens");
//
//     widget.faceRecognitionViewState.faceDetectionViewController =
//         FaceDetectionViewController(id, widget);
//
//     await widget.faceRecognitionViewState.faceDetectionViewController
//         ?.initHandler();
//
//     int? livenessLevel = prefs.getInt("liveness_level");
//     await widget.faceRecognitionViewState._facesdkPlugin
//         .setParam({'check_liveness_level': livenessLevel ?? 0});
//
//     await widget.faceRecognitionViewState.faceDetectionViewController
//         ?.startCamera(cameraLens ?? 1);
//   }
// }
//
// class FacePainter extends CustomPainter {
//   dynamic faces;
//   double livenessThreshold;
//
//   FacePainter({required this.faces, required this.livenessThreshold});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (faces != null) {
//       var paint = Paint();
//       paint.color = const Color.fromARGB(0xff, 0xff, 0, 0);
//       paint.style = PaintingStyle.stroke;
//       paint.strokeWidth = 3;
//
//       for (var face in faces) {
//         double xScale = face['frameWidth'] / size.width;
//         double yScale = face['frameHeight'] / size.height;
//
//         String title = "";
//         Color color = const Color.fromARGB(0xff, 0xff, 0, 0);
//         if (face['liveness'] < livenessThreshold) {
//           color = const Color.fromARGB(0xff, 0xff, 0, 0);
//           title = "Spoof${face['liveness']}";
//         } else {
//           color = const Color.fromARGB(0xff, 0, 0xff, 0);
//           title = "Real ${face['liveness']}";
//         }
//
//         TextSpan span =
//             TextSpan(style: TextStyle(color: color, fontSize: 20), text: title);
//         TextPainter tp = TextPainter(
//             text: span,
//             textAlign: TextAlign.left,
//             textDirection: TextDirection.ltr);
//         tp.layout();
//         tp.paint(canvas, Offset(face['x1'] / xScale, face['y1'] / yScale - 30));
//
//         paint.color = color;
//         canvas.drawRect(
//             Offset(face['x1'] / xScale, face['y1'] / yScale) &
//                 Size((face['x2'] - face['x1']) / xScale,
//                     (face['y2'] - face['y1']) / yScale),
//             paint);
//       }
//     }
//   }
//
//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
