import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'api_config.dart';

class ChatScreen extends StatefulWidget {
  final String contactId;
  final String contactName;
  final String? contactPhoto;
  final Map<String, dynamic> userData;

  const ChatScreen({
    super.key,
    required this.contactId,
    required this.contactName,
    this.contactPhoto,
    required this.userData,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  Timer? _messagePollingTimer;
  bool _isLoading = false;
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _startMessagePolling();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagePollingTimer?.cancel();
    super.dispose();
  }

  void _startMessagePolling() {
    _messagePollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _fetchMessages(),
    );
  }

  Future<void> _fetchMessages() async {
    if (_isLoading && !_isInitialLoad) return;

    if (_isInitialLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.fetchMessagesURL), // Adicione esta URL no ApiConfig
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_id': widget.userData['id'],
          'contact_id': widget.contactId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['status'] == 'success') {
          final List<dynamic> messagesData = data['messages'] ?? [];

          final newMessages = messagesData
              .map((msg) => ChatMessage(
                    id: msg['id']?.toString() ?? '',
                    sender: msg['remetente_id']?.toString() ?? '',
                    senderName: msg['sender_name'] ?? widget.contactName,
                    message: msg['mensagem'] ?? '',
                    timestamp: DateTime.tryParse(msg['data_envio'] ?? '') ??
                        DateTime.now(),
                    isMe: msg['remetente_id']?.toString() ==
                        widget.userData['id']?.toString(),
                  ))
              .toList();

          // Só atualiza se houve mudanças nas mensagens
          if (_messagesChanged(newMessages)) {
            setState(() {
              _messages.clear();
              _messages.addAll(newMessages);
            });

            // Auto-scroll para a última mensagem
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }
      }
    } catch (e) {
      if (_isInitialLoad) {
        print('Erro ao carregar mensagens: $e');
      }
    } finally {
      if (_isInitialLoad) {
        setState(() {
          _isLoading = false;
          _isInitialLoad = false;
        });
      }
    }
  }

  bool _messagesChanged(List<ChatMessage> newMessages) {
    if (_messages.length != newMessages.length) return true;

    for (int i = 0; i < _messages.length; i++) {
      if (_messages[i].id != newMessages[i].id ||
          _messages[i].message != newMessages[i].message) {
        return true;
      }
    }
    return false;
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Adiciona mensagem localmente primeiro (UI responsiva)
    final tempMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      sender: widget.userData['id']?.toString() ?? '',
      senderName: widget.userData['username'] ?? 'Eu',
      message: text.trim(),
      timestamp: DateTime.now(),
      isMe: true,
    );

    setState(() {
      _messages.add(tempMessage);
    });

    _messageController.clear();

    // Auto-scroll para a nova mensagem
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendMessageURL), // Adicione esta URL no ApiConfig
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'sender_id': widget.userData['id'],
          'recipient_id': widget.contactId,
          'message': text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true && data['status'] != 'success') {
          // Remove mensagem temporária em caso de erro
          setState(() {
            _messages.removeWhere((msg) => msg.id == tempMessage.id);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Erro ao enviar mensagem: ${data['message'] ?? 'Erro desconhecido'}'),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          // Busca mensagens atualizadas do servidor
          _fetchMessages();
        }
      } else {
        // Remove mensagem temporária em caso de erro
        setState(() {
          _messages.removeWhere((msg) => msg.id == tempMessage.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro de conexão ao enviar mensagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Remove mensagem temporária em caso de erro
      setState(() {
        _messages.removeWhere((msg) => msg.id == tempMessage.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar mensagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  _buildContactAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.contactName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Online', // Você pode implementar status real depois
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 16),
                  const Icon(Icons.more_vert, color: Colors.white, size: 20),
                ],
              ),
            ),

            // Messages area
            Expanded(
              child: _isInitialLoad && _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma mensagem ainda',
                                style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Envie uma mensagem para começar a conversa',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _messages.length +
                              (_messages.isNotEmpty
                                  ? 1
                                  : 0), // +1 for date separator if has messages
                          itemBuilder: (context, index) {
                            if (index == 0 && _messages.isNotEmpty) {
                              // Date separator
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade800,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatDate(_messages.first.timestamp),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final message = _messages[index - 1];
                            return _buildMessageBubble(message);
                          },
                        ),
            ),

            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade800, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.attach_file,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Enviar uma mensagem',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: _sendMessage,
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_messageController.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          const Icon(Icons.send, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactAvatar() {
    if (widget.contactPhoto != null && widget.contactPhoto!.isNotEmpty) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            widget.contactPhoto!,
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildDefaultAvatar();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: _getAvatarColor(widget.contactName),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.contactName.isNotEmpty
              ? widget.contactName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getAvatarColor(String name) {
    final hash = name.hashCode;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            _buildMessageAvatar(message),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!message.isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(message.timestamp),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: message.isMe
                        ? Colors.blue.shade600
                        : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    message.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (message.isMe)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (message.isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getAvatarColor(widget.userData['username'] ?? 'U'),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  widget.userData['username']?.toString().isNotEmpty == true
                      ? widget.userData['username'][0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageAvatar(ChatMessage message) {
    if (widget.contactPhoto != null && widget.contactPhoto!.isNotEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.network(
            widget.contactPhoto!,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getAvatarColor(widget.contactName),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.contactName.isNotEmpty
                        ? widget.contactName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: _getAvatarColor(widget.contactName),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.contactName.isNotEmpty
              ? widget.contactName[0].toUpperCase()
              : 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    final months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez'
    ];

    return '${dateTime.day} de ${months[dateTime.month - 1]} de ${dateTime.year}';
  }
}

class ChatMessage {
  final String id;
  final String sender;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isMe;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isMe,
  });
}
