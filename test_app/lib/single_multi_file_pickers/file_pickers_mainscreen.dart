import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FilePickerMainScreen extends StatefulWidget {
  const FilePickerMainScreen({Key? key}) : super(key: key);

  @override
  _FilePickerMainScreenState createState() => _FilePickerMainScreenState();
}

class _FilePickerMainScreenState extends State<FilePickerMainScreen> {

  final ImagePicker picker = ImagePicker();
  XFile? imageFile;
  File? pickedSingle;
  List<XFile>? multiImageFiles;
  List<File>? pickedMultiple;
  String? selectedImage;
  bool selectedImageShow = false;

  uploadImage(File imageFile) async {
    print("IMAGE PATH--${basename(imageFile.path)}");
    var stream = http.ByteStream(Stream.castFrom(imageFile.openRead()));
    var length = await imageFile.length();
    var uri = Uri.parse("https://api.imgur.com/3/upload");
    var request = http.MultipartRequest("POST", uri);
    request.fields['title'] = "Single Image";
    request.fields['name'] = "profilePic";
    request.headers['Authorization'] = "";
    var multipartFile = http.MultipartFile('image', stream, length, filename: basename(imageFile.path));
    request.files.add(multipartFile);
    var response = await request.send();
    var responsed = await http.Response.fromStream(response);
    var resultResponse = jsonDecode(responsed.body);
    print("_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_");
    print(resultResponse);
    print(response.statusCode);
    print(resultResponse['data']['id']);
    // response.stream.transform(utf8.decoder).listen((value) {
    //   print(value);
    //   var res = jsonDecode(value);
    //   print(res['data']['id']);
    //   setState(() {
    //     selectedImage = res['data']['link'];
    //   });
    // });
  }

  uploadMultipleImages(List<XFile> images)async{
    var uri = Uri.parse("https://api.imgur.com/3/upload");
    var responseData;
    print("imagesLength-----${images.length}");
    List<http.MultipartFile> imageList = [];

    for(var i=0; i<images.length; i++){
      var request = http.MultipartRequest("POST", uri);
      print("Loading...");
      File image = File(images[i].path);
      var stream = http.ByteStream(Stream.castFrom(image.openRead()));
      var length = await image.length();
      request.fields['name'] = "--------- SELECTED PIC $i -------";
      var multipartFile = http.MultipartFile("image",stream, length, filename: basename(image.path));
      imageList.add(multipartFile);
      request.files.add(multipartFile);
      var response = await request.send();
      responseData = await http.Response.fromStream(response);
      var resultResponse = jsonDecode(responseData.body);
      print("_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_");
      print(resultResponse);
      print(responseData.statusCode);
    }


    print(imageList);
    print("imageLIST___---${imageList.length}");

    // print("req files Length****  ${request.files.length}");
    // print(request.files);


    // response.stream.transform(utf8.decoder).listen((value) {
    //   print(value);
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Single & Multi File Picker"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(onPressed:()async{
              XFile? pickedFile = (await picker.pickImage(source: ImageSource.gallery));
              if(pickedFile != null) {
                setState(() {
                imageFile = pickedFile;
                pickedSingle = File(pickedFile.path);
                });
              }
            },
                child: const Text("Single")),
            ElevatedButton(onPressed: ()async{
              List<XFile>? pickedMultiFiles = await picker.pickMultiImage();
              if(pickedMultiFiles != null) {
                setState(() {
                multiImageFiles = pickedMultiFiles;
              });
                print("LENGTH FILE-----${multiImageFiles?.length}");
              }
              print("LENGTH___---___---${pickedMultiFiles!.length}");
            },
                child: const Text("Mulitple") ),
            if(imageFile != null) ...[
              const SizedBox(height: 5,),
              const Text("Single IMAGE selected"),
               const SizedBox(height: 5,),
              Container(
                height: 150,
                width: 150,
                child: Image.file(pickedSingle!,fit: BoxFit.cover,),
              ) ,
            const SizedBox(height: 5,),
            ElevatedButton(onPressed:(){
             uploadImage(pickedSingle!);
            },
                child: const Text("UPLOAD")),
              // if(selectedImage != null)...[
              //   const SizedBox(height: 5,),
              //   ElevatedButton(onPressed:()async{
              //   setState(() {
              //     selectedImageShow = !selectedImageShow;
              //   });
              //   },
              //       child:const Text("Get Image")),
              //   if(selectedImageShow)
              //   SizedBox(
              //     height: 150,
              //     width: 150,
              //     child: Image.network(selectedImage!,fit: BoxFit.cover,),
              //   ),
              // ]
            ] ,
            if(multiImageFiles != null)...[
               const SizedBox(height: 5,),
              const Text("Multiple IMAGES selected"),
               const SizedBox(height: 5,),
              Expanded(
                child: GridView.builder(
                  itemCount: multiImageFiles!.length,
                    gridDelegate:const
                    SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                    itemBuilder: (context ,index){
                         return Container(
                           margin: const EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                           height: 150,
                           width: 150,
                           child: Image.file(File(multiImageFiles![index].path),
                           fit: BoxFit.cover,),
                         );
                    }),
              ),
              const SizedBox(height: 5,),
              ElevatedButton(onPressed:(){
               uploadMultipleImages(multiImageFiles!);
              },
                  child: const Text("UPLOAD"))
            ]
          ],
        ),
      ),
    );
  }
}
