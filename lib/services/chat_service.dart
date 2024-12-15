// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:prime_store/screens/funcionalities/chat/chat_view_screen.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatService {
  // Método para iniciar el chat entre el comprador y el vendedor
  Future<void> startChat(String buyerId, String sellerId, BuildContext context) async {
    final client = Provider.of<StreamChatClient>(context, listen: false);
    final channelId = 'chat-$buyerId-$sellerId'; // ID del canal
    final channel = client.channel('messaging', id: channelId);

    try {
      // Intentamos observar el canal
      await channel.watch();

      // Verifica si el canal ya tiene mensajes
      final channelState = channel.state;
      if (channelState!.messages.isEmpty) {
        // Si no hay mensajes, lo creamos
        await channel.create();
        await channel.addMembers([buyerId, sellerId]);
        // Espera a que el canal esté listo antes de continuar
        await channel.watch();
      }

      // Navega a la pantalla de chat
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatViewScreen(channel: channel)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar el chat: $e')),
      );
    }
  }
}
