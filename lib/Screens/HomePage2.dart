import 'dart:developer';
import 'dart:typed_data';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final Gemini gemini = Gemini.instance;
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(id: "1", firstName: "Gemini");
  List<ChatMessage> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black38,
        title: Text(
          "Google Gemini",
          style: GoogleFonts.poppins(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: <Color>[
                    Colors.blue,
                    Colors.white
                    //add more color here.
                  ],
                ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 100.0))),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return DashChat(
      inputOptions: InputOptions(
        leading: [
          IconButton(
            onPressed: (){
              _sendMediaMessage();
            },
            icon: const Icon(
              Icons.photo_size_select_actual,
              color: Colors.indigoAccent,
            ),
          ),
        ],
        inputTextStyle: GoogleFonts.poppins(fontSize: 20),
        inputToolbarPadding: const EdgeInsets.all(10),
        alwaysShowSend: true,
        sendOnEnter: true,
        cursorStyle: const CursorStyle(
          color: Colors.deepPurple,
          width: 2.0,
        ),
      ),
      messageOptions: MessageOptions(
        showTime: true,
        currentUserContainerColor: Colors.blueGrey[300],
        currentUserTimeTextColor: Colors.black,
      ),
      currentUser: currentUser,
      onSend: _sendMessage,
      messages: messages,
    );
  }

  void _sendMessage(ChatMessage chatMessage) {
    setState(() {
      messages = [chatMessage, ...messages];
    });
    String question = chatMessage.text;

    gemini.streamGenerateContent(question).listen((event) {
      String? response = event.content?.parts?.fold(
          "", (previous, current) => "$previous${current.text}"
      ) ?? "";

      ChatMessage geminiMessage = ChatMessage(
        user: geminiUser,
        createdAt: DateTime.now(),
        text: response,
      );

      setState(() {
        messages = [geminiMessage, ...messages];
      });
    }).onError((e) {
      log('streamGenerateContent exception', error: e);
    });
  }
  void _sendMediaMessage() async {
    try {
      // Use ImagePicker to pick an image from the gallery
      ImagePicker imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final Uint8List imageBytes = await pickedFile.readAsBytes();

        gemini.textAndImage(
            text: "What is this picture?", // text
            images: [imageBytes] // list of images
        )
            .then((value) => log(value?.content?.parts?.last.text ?? ''))
            .catchError((e) => log('textAndImageInput', error: e));
      } else {
        log('No image selected.');
      }
    } catch (e) {
      log('Error loading image', error: e);
    }
  }

}
