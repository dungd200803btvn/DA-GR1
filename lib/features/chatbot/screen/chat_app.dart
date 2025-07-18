import 'dart:convert';
import 'package:app_my_app/data/repositories/product/product_repository.dart';
import 'package:app_my_app/features/chatbot/controller/chatbot_controller.dart';
import 'package:app_my_app/features/shop/controllers/product/cart_controller.dart';
import 'package:app_my_app/utils/popups/loader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../common/widgets/appbar/appbar.dart';
import '../../../common/widgets/images/t_circular_image.dart';
import '../../../data/repositories/authentication/authentication_repository.dart';
import '../../../utils/constants/api_constants.dart';
import '../../../utils/formatter/formatter.dart';
import '../../personalization/controllers/user_controller.dart';
import '../../personalization/screens/setting/setting.dart';
import '../../shop/models/product_model.dart';
import '../../shop/screens/cart/cart.dart';
import '../../shop/screens/checkout/checkout.dart';
import '../model/chat_button_model.dart';
import '../model/message_model.dart';

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rasa Chat Bot',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<MessageModel> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final ChatbotController chatbotController = ChatbotController.instance;
  final CartController cartController = CartController.instance;
  final String userId = AuthenticationRepository.instance.authUser!.uid;
  final ProductRepository productRepository = ProductRepository.instance;
  Future<void> loadMessages(String userId) async {
    final messages = await chatbotController.fetchAllMessagesByUser(userId);
    setState(() {
      _messages.clear();
      _messages.addAll(messages);
    });
    // Đợi 1 chút để đảm bảo ListView đã build xong
    await Future.delayed(Duration(milliseconds: 100));
    _scrollToBottom();
  }

  @override
  void initState() {
    super.initState();
    loadMessages(userId);
  }

  // ⚠️ Sửa URL nà
  Future<void> _sendMessage(String text,bool isDisplay) async {
    if (text.trim().isEmpty) return;
    if(isDisplay){
      final message = MessageModel(
        text: text,
        isUser: true,
        createdAt: Timestamp.now().toDate(),
      );
      setState(() {
        _messages.add(message);
        _controller.clear();
      });
      await chatbotController.saveMessageToFirestore(userId, message);
      _scrollToBottom();
    }
    try {
      final response = await http.post(
        Uri.parse(rasaUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"sender": "user", "message": text}),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        if (data.isEmpty) {
          final message = MessageModel(
            text: "❗ Không có kết quả phù hợp.",
            isUser: false,
            createdAt: Timestamp.now().toDate(),
          );
          setState(() {
            _messages.add(message);
          });
          _scrollToBottom();
          await chatbotController.saveMessageToFirestore(userId, message);
        } else {
          for (var item in data) {
            if (item['text'] != null) {
              final buttons = (item['buttons'] as List?) ?? [];
              final message = MessageModel(
                text: item['text'],
                isUser: false,
                createdAt: Timestamp.now().toDate(),
                buttons: buttons
                    .map((btn) => ChatButton(
                          title: btn['title'],
                          payload: btn['payload'],
                        ))
                    .toList(),
              );
              setState(() {
                _messages.add(message);
              });
              _scrollToBottom();
              await chatbotController.saveMessageToFirestore(userId, message);
            }
            if (item['custom'] != null) {
              final jsonMessage = item['custom'];
              final type = jsonMessage['type'];
              switch (type) {
                case 'add_to_cart':
                  final data = jsonMessage['data'];
                  print('Data: $data');
                  print('Id: ${data['id']}');
                  print('quantity: ${data['quantity']}');
                  final product = await  productRepository.getProductById(data['id']);
                  print('Product: ${product?.toJson()}');
                  final quantity = data['quantity'];
                  cartController.productQuantityInCart.value = quantity;
                  cartController.addToCart(product!);
                  TLoader.successSnackbar(
                      title: 'Thêm vào giỏ hàng thành công');
                  break;
                case 'view_cart':
                  TLoader.successSnackbar(title: 'Xem giỏ hàng thành công');
                  // Cập nhật UI giỏ hàng, hoặc show modal cart nếu muốn
                  Get.to(() => const CartScreen());
                  break;

                case 'place_order':
                  // Gọi hàm đặt hàng / xử lý đơn hàng
                  TLoader.successSnackbar(title: 'Đặt hàng thành công');

                  Get.to(() => const CheckoutScreen());
                  break;

                default:
                  // Xử lý các type khác nếu cần
                  break;
              }
            }
          }
        }
      } else {
        final message = (MessageModel(
          text: "❗ Bot không phản hồi. Lỗi ${response.statusCode}",
          isUser: false,
          createdAt: Timestamp.now().toDate(),
        ));
        setState(() {
          _messages.add(message);
        });
        _scrollToBottom();
        await chatbotController.saveMessageToFirestore(userId, message);
      }
    } catch (e) {
      print('Loi ket noi: o chat app screen: $e');
      final message = MessageModel(
        text: "❗ Lỗi kết nối: $e",
        isUser: false,
        createdAt: Timestamp.now().toDate(),
      );
      setState(() {
        _messages.add(message);
        if (kDebugMode) {
          print("❗ Lỗi kết nối: $e");
        }
      });
      _scrollToBottom();
      await chatbotController.saveMessageToFirestore(userId, message);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: TAppBar(
        showBackArrow: true,
        title: Text(
          "💬 Chat với Bot",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        leadingOnPressed: () => Get.to(const SettingScreen()),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: message.isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!message.isUser)
                        const TCircularImage(
                          image: "assets/images/content/chat_bot.jpg",
                          width: 50,
                          height: 50,
                          padding: 0,
                          isNetworkImage: false,
                          fit: BoxFit.cover,
                        ),
                      if (!message.isUser) const SizedBox(width: 2),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.7),
                          decoration: BoxDecoration(
                            color: message.isUser
                                ? Colors.indigo
                                : Colors.grey[300],
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft:
                                  Radius.circular(message.isUser ? 12 : 0),
                              bottomRight:
                                  Radius.circular(message.isUser ? 0 : 12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.text,
                                style: TextStyle(
                                  color: message.isUser
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (message.buttons != null &&
                                  message.buttons!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: message.buttons!.map((btn) {
                                      return ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.indigo,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18)),
                                        ),
                                        onPressed: () {
                                          _sendMessage(btn
                                              .payload,false); // gửi như người dùng gõ tay
                                        },
                                        child: Text(btn.title),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                DFormatter.FormattedDate(message.createdAt),
                                style: TextStyle(
                                  color: message.isUser
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (message.isUser) const SizedBox(width: 2),
                      if (message.isUser)
                        TCircularImage(
                          image: controller.user.value.profilePicture,
                          width: 50,
                          height: 50,
                          padding: 0,
                          isNetworkImage:
                              controller.user.value.profilePicture.isNotEmpty,
                          fit: BoxFit.cover,
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      ),
                      onSubmitted: (text) {
                        _sendMessage(text, true); // Người dùng nhập tay
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Nút gửi
                  CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () => _sendMessage(_controller.text, true),
                    ),
                  ),
                ],
              ),
            ),
          )

        ],
      ),
    );
  }
}
