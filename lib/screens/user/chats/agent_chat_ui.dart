import 'dart:convert';

import 'package:dragnet/models/requests/chats/AgentChat_Request.dart';
import 'package:dragnet/models/responses/chats/ListAgentChat_Response.dart';
import 'package:dragnet/models/responses/error_response.dart';
import 'package:dragnet/services/api_services.dart';
import 'package:dragnet/utils/Utility.dart';
import 'package:dragnet/utils/colors.dart';
import 'package:dragnet/utils/constants.dart';
import 'package:dragnet/utils/custom_textstyles.dart';
import 'package:dragnet/utils/service_urls.dart';
import 'package:dragnet/widgets/bubble.dart';
import 'package:dragnet/widgets/custom_profile_image.dart';
import 'package:dragnet/widgets/custom_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentChatPage extends StatefulWidget {
  final int agentId;

  AgentChatPage({
    Key key,
    this.agentId,
  }) : super(key: key);

  @override
  _AgentChatPageState createState() => _AgentChatPageState();
}

class _AgentChatPageState extends State<AgentChatPage> {
  int _userId;
  String _profileImage, _userName, _email;
  int _agentId;
  bool _isLoading = false;
  List<ListAgentChatResponse> _chatList = List();

  @override
  void initState() {
    super.initState();
    _agentId = widget.agentId;
    _loadGlobalValues();
  }

  void _loadGlobalValues() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('UserName') ?? '';
      _email = prefs.getString('Email') ?? '';
      _userId = prefs.getInt('UserId') ?? '';
      _profileImage = prefs.getString('ProfileImage') ?? "";
    });
    _checkInternetConnection();
  }

  void _checkInternetConnection() async {
    bool connectionResult = await Utility.checkConnection();
    if (connectionResult) {
      await _getAgentChatList();
    } else {
      Utility.showToast(context, Error_No_Internet_Text);
    }
  }

  Future _getAgentChatList() async {
    try {
      setState(() {
        _isLoading = true;
      });
      var url = Get_ListAgentChat_Url + "$_agentId" + "&userId=$_userId";
      print("url $url");
      print("url $url");
      API.getAPI(url, "").then((response) async {
        int statusCode = response.statusCode;
        setState(() {
          _isLoading = false;
        });
        print("statusCode $statusCode");

        if (statusCode == 200) {
          Iterable list = json.decode(response.body);
          print("list ${list}");

          _chatList = list
              .map((model) => ListAgentChatResponse.fromJson(model))
              .toList();
          print("_chatList ${_chatList.length}");
        }
      });
    } catch (e) {
      print("_getChatList $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Hi, " + _userName,
          style: GoogleFonts.sourceSansPro(
            fontSize: 20,
            color: Color.fromRGBO(36, 36, 36, 1),
            fontWeight: FontSemiBold,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: CustomProgressBar(
        isLoading: _isLoading,
        widget: Column(
          children: <Widget>[
            Expanded(
              child: _chatList.length != 0
                  ? _messageListView(_chatList)
                  : SizedBox(),
            ),
            _bottomTextBox(),
          ],
        ),
      ),
    );
  }

  Widget _messageListView(List<ListAgentChatResponse> items) {
    return ListView.builder(
      //cacheExtent: 9999,
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: 15,
      ),
      reverse: true,
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Container(
          child: items[index].senderId == _userId
              ? Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Flexible(
                        child: Bubble(
                          color: AshColor,
                          style: msgStyleMe,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 3, bottom: 3),
                            child: _customText(
                              items[index].name,
                              items[index].comment,
                              items[index].commentDate,
                              msgNameTextStyle,
                              msgTimeTextStyle,
                            ),
                          ),
                        ),
                      ),
                      CustomProfileImage(
                          url: items[index].profileImage, radius: 26),
                    ],
                  ),
                )
              : Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      CustomProfileImage(
                          url: items[index].profileImage, radius: 26),
                      Flexible(
                        child: Bubble(
                          color: AshColor,
                          style: msgStyleSomebody,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 10, right: 10, top: 3, bottom: 3),
                            child: _customText(
                              items[index].name,
                              items[index].comment,
                              items[index].commentDate,
                              msgNameTextStyle,
                              msgTimeTextStyle,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  final TextEditingController _textEditingController =
      new TextEditingController();
  Widget _bottomTextBox() {
    return Container(
      margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(209, 209, 209, 1), width: 1),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 5,
          ),
          CustomProfileImage(url: _profileImage, radius: 20),
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: TextFormField(
              controller: _textEditingController,
              style: textBoxTextStyleBlack,
              onChanged: (String messageText) {
                setState(() {
                  _isComposingMessage = messageText.length > 0;
                });
                if (messageText.length > 0) {
                  setState(() {
                    _isShowSendButton = true;
                  });
                } else {
                  setState(() {
                    _isShowSendButton = false;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: "Type your comments...",
                border: InputBorder.none,
                hintStyle: textBoxHintTextStyle,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: _isShowSendButton ? getDefaultSendButton() : SizedBox(),
          ),
        ],
      ),
    );
  }

  bool _isComposingMessage = true;
  bool _isShowSendButton = false;
  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(
        Icons.send,
        color: BlueColor,
      ),
      onPressed: _isComposingMessage ? () => _sendMessageRequest() : null,
    );
  }

  Widget _customText(String user, String msg, String date, TextStyle msgStyle,
      TextStyle dateStyle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              user,
              style: msgStyle,
            ),
            SizedBox(
              height: 2,
            ),
            Text(
              msg,
              style: msgTextStyle,
            ),
          ],
        )),
        SizedBox(
          width: 10,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.only(top: 22),
            child: Text(
              date,
              style: dateStyle,
            ),
          ),
        )
      ],
    );
  }

  void _sendMessageRequest() async {
    FocusScope.of(context).requestFocus(FocusNode());
    try {
      bool connectionResult = await Utility.checkConnection();
      if (connectionResult) {
        setState(() {
          _isLoading = true;
        });
        AgentChatRequest newPost = new AgentChatRequest(
          comment: _textEditingController.text,
          parentId: 0,
          senderId: _userId,
          receiverId: _agentId,
        );
        await sendMessagePost(Post_AgentChat_Url, body: newPost.toMap());
      } else {
        Utility.showToast(context, Error_No_Internet_Text);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future sendMessagePost(String url, {Map body}) async {
    try {
      API.postAPI(url, "", body).then((response) async {
        final int statusCode = response.statusCode;
        if (statusCode == 200) {
          _textEditingController.text = '';
          Iterable json = jsonDecode(response.body);
          print("json $json");
          List<ListAgentChatResponse> item = json
              .map((model) => ListAgentChatResponse.fromJson(model))
              .toList();

          setState(() {
            _isLoading = false;
            _isShowSendButton = false;
            var _msgChat = item[0];
            _chatList.insert(
                0,
                ListAgentChatResponse(
                  senderId: _msgChat.senderId,
                  comment: _msgChat.comment,
                  commentDate: _msgChat.commentDate,
                  crimeId: _msgChat.crimeId,
                  name: _msgChat.name,
                  parentId: _msgChat.parentId,
                  profileImage: _msgChat.profileImage,
                  search: _msgChat.search,
                  agentChatId: _msgChat.agentChatId,
                ));
            _chatList = _chatList;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
          final Map parsed = json.decode(response.body);
          final user = ErrorResponse.fromJson(parsed);
          var error = user.errorMessage;
          Utility.showToast(context, error);
          _textEditingController.text = "";
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
