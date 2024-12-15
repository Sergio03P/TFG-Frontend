import 'package:flutter/material.dart';
import 'package:prime_store/providers/bottom_index_navigation_provider.dart';
import 'package:prime_store/screens/funcionalities/chat/chat_view_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

//Clase que muestra la lista de chats con otros usuarios
class _ChatListScreenState extends State<ChatListScreen> {
  late StreamChannelListController _listController; //controlador de la lista de chats
  final ValueNotifier<int> unreadCountNotifier = ValueNotifier<int>(0); // Notificador para mensajes no leídos

  @override
  void initState() {
    super.initState();
    _initializeListController(); // Inicializamos el controlador aquí
  }

  //Método que inicializa el controlador de la lista de canales
  void _initializeListController() {
    final client = StreamChat.of(context).client; //obtenemos el cliente de StremChat en el contexto
    final userId = StreamChat.of(context).currentUser!.id; //obtenemos el id del usuario actual

    _listController = StreamChannelListController( //inicializamos el controlador
      client: client,
      filter: Filter.and([ //filtros que se aplican para mostrarlos en la lista o no
        Filter.in_('members', [userId]), // Filtra los canales donde el usuario actual es miembro
        Filter.exists('last_message_at'), // Solo muestra canales con mensajes
      ]),
      channelStateSort: const [SortOption('last_message_at')], //muestra el último mensaje en la lista de chat
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Mis Chats'),
        leading: IconButton(
          onPressed: (){
            Provider.of<BottomIndexNavigationProvider>(context,listen: false).setIndex = 0;
            Navigator.pop(context);
          }, 
          icon: const Icon(Icons.arrow_back)
        ),
      ),
      body: StreamChannelListView( //List view con los canales de chats
        loadingBuilder: (context) {
          return const Center(child: CircularProgressIndicator(color: Colors.lightBlue));
        },
        controller: _listController, //controlador de la lista
        onChannelTap: (channel) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StreamChannel(
                channel: channel,
                child: ChatViewScreen(channel: channel), //canal privado con el usuario seleccionado
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() { //se liberan los recursos
    _listController.dispose();
    super.dispose();
  }
}

