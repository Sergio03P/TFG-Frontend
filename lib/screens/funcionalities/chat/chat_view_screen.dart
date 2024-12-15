import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

//Clase para mostar el chat privado con otro usuario
class ChatViewScreen extends StatefulWidget {
  final Channel channel;

  //Constructor
  const ChatViewScreen({super.key, required this.channel});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  //Controlador del campo de texto
  final StreamMessageInputController messageInputController = StreamMessageInputController();
  final focusNode = FocusNode(); //controla el foco del texto

  void reply(Message message) {
    messageInputController.quotedMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }

  //Método para marcar los mensajes como léido
  Future<void> _markChannelAsRead() async {
    await widget.channel.markRead();
  }

  @override
  void initState() { //cuando se monta la pantalla se marcan los mensajes como léidos directamente
    super.initState();
    _markChannelAsRead();
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.channel.name ?? 'Chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamMessageListView(
                messageBuilder: (context, messageDetails, messages, defaultWidget) {
                  //const threshold = 0.2;
                  final isMyMessage = messageDetails.isMyMessage;
                  final swipeDirection = isMyMessage ? SwipeDirection.endToStart : SwipeDirection.startToEnd;
                  final message = messageDetails.message;

                  // Crear el indicador de estado (doble tick)
                  Widget statusIndicator = Container();

                  // Verificar si el mensaje es enviado por el usuario actual
                  if (isMyMessage) {
                    // Verificar el estado de envío
                    if (message.state == MessageState.sending) {
                      statusIndicator = const Icon(Icons.done, color: Colors.grey); // Enviando
                    } else if (message.state == MessageState.sent) {
                      // Verificar si el mensaje ha sido leído por el usuario actual
                      final readState = widget.channel.state?.read;
                      bool isRead = false;

                      // Recorremos los miembros del canal para comprobar si el mensaje ha sido leído
                      for (var read in readState ?? []) {
                        if (read.user.id == StreamChat.of(context).currentUser?.id) {
                          // Si el mensaje fue leído por el usuario actual
                          if (read.lastRead != null && message.createdAt.isBefore(read.lastRead!)) {
                            isRead = true;
                          }
                          break;
                        }
                      }

                      // Mostrar el estado de lectura del mensaje
                      if (isRead) {
                        statusIndicator = const Icon(Icons.done_all, color: Colors.blue); // Leído (doble tick azul)
                      } else {
                        statusIndicator = const Icon(Icons.done_all, color: Colors.grey); // Enviado (doble tick gris)
                      }
                    }
                  }

                  return Swipeable(
                    key: ValueKey(messageDetails.message.id),
                    direction: swipeDirection,
                    //swipeThreshold: threshold,
                    onSwiped: (details) => reply(messageDetails.message),
                    backgroundBuilder: (context, details) {
                      final alignment = isMyMessage
                          ? Alignment.centerRight
                          : Alignment.centerLeft;
                      return Align(
                        alignment: alignment,
                        child: statusIndicator,
                      );
                    },
                    child: defaultWidget.copyWith(onReplyTap: reply),
                  );
                },
                messageFilter: (message) {
                  return true;
                },
              ),
            ),
            StreamMessageInput(
              messageInputController: messageInputController,
              onQuotedMessageCleared: messageInputController.clearQuotedMessage,
              focusNode: focusNode,
            ),
          ],
        ),
      ),
    );
  }
}



