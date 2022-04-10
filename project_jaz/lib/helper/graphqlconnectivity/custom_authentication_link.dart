// import 'dart:async';
//
// import 'dart:io';
//
//
// typedef GetHeaders = Future<Map<String, String>> Function();
//
// class CustomAuthLink extends Link {
//   CustomAuthLink({
//     this.getHeaders,
//   }) : super(
//     request: (Operation operation, [NextLink forward]) {
//       StreamController<FetchResult> controller;
//
//       Future<void> onListen() async {
//         try {
//           final Map<String, String> headers = await getHeaders();
//
//           operation.setContext(<String, Map<String, String>>{
//             'headers': headers
//           });
//         } catch (error) {
//           controller.addError(error);
//         }
//
//         await controller.addStream(forward(operation));
//         await controller.close();
//       }
//
//       controller = StreamController<FetchResult>(onListen: onListen);
//
//       return controller.stream;
//     },
//   );
//
//   GetHeaders getHeaders;
// }