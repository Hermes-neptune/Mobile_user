import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'api_config.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String? groupPhoto;
  final Map<String, dynamic> userData;

  const GroupChatScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.userData,
    this.groupPhoto,
  });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> members = [];
  bool isLoading = false;
  bool isLoadingMembers = false;
  bool isSendingMessage = false;
  bool _isInitialLoad = true;
  Map<String, dynamic>? groupInfo;
  Timer? _messagePollingTimer;

  // Para paginação
  bool hasMore = true;
  int currentOffset = 0;
  final int messagesLimit = 50;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadMembers();
    _loadGroupInfo();
    _startMessagePolling();

    // Adicionar listener para scroll (para carregar mais mensagens)
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messagePollingTimer?.cancel();
    super.dispose();
  }

  void _startMessagePolling() {
    _messagePollingTimer = Timer.periodic(
      const Duration(seconds: 3),
      (timer) => _fetchNewMessages(),
    );
  }

  Future<void> _fetchNewMessages() async {
    // Não buscar se estiver carregando mensagens iniciais ou enviando
    if ((isLoading && _isInitialLoad) || isSendingMessage) return;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.messageGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
          'limite': messagesLimit,
          'offset': 0, // Sempre buscar as mensagens mais recentes
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newMessages =
              List<Map<String, dynamic>>.from(data['mensagens'] ?? []);

          // Só atualiza se houve mudanças nas mensagens
          if (_messagesChanged(newMessages)) {
            setState(() {
              messages = newMessages;
            });

            // Auto-scroll para a última mensagem se estava próximo do fim
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController.hasClients) {
                final maxScroll = _scrollController.position.maxScrollExtent;
                final currentScroll = _scrollController.position.pixels;

                // Se estava nos últimos 100 pixels, fazer scroll automático
                if (maxScroll - currentScroll < 100) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              }
            });
          }
        }
      }
    } catch (e) {
      // Silenciar erros do polling automático
      if (_isInitialLoad) {
        print('Erro no polling de mensagens: $e');
      }
    }
  }

  bool _messagesChanged(List<Map<String, dynamic>> newMessages) {
    if (messages.length != newMessages.length) return true;

    for (int i = 0; i < messages.length; i++) {
      if (messages[i]['id']?.toString() != newMessages[i]['id']?.toString() ||
          messages[i]['mensagem'] != newMessages[i]['mensagem']) {
        return true;
      }
    }
    return false;
  }

  void _onScroll() {
    if (_scrollController.position.pixels == 0 && hasMore && !isLoading) {
      _loadMoreMessages();
    }
  }

  Future<void> _loadGroupInfo() async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.infoGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            groupInfo = data['grupo'];
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar info do grupo: $e');
    }
  }

  Future<void> _loadMessages({bool isRefresh = false}) async {
    if (isLoading && !_isInitialLoad) return;

    if (_isInitialLoad) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.messageGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
          'limite': messagesLimit,
          'offset': isRefresh ? 0 : currentOffset,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final newMessages =
              List<Map<String, dynamic>>.from(data['mensagens'] ?? []);

          setState(() {
            if (isRefresh) {
              messages = newMessages;
              currentOffset = 0;
            } else {
              messages = [...newMessages, ...messages];
            }

            hasMore = data['pagination']?['has_more'] ?? false;

            // Atualizar informações do grupo se disponível
            if (data['grupo_info'] != null) {
              groupInfo = data['grupo_info'];
            }
          });

          if (isRefresh) {
            _scrollToBottom();
          }
        } else {
          _showErrorSnackBar(data['message'] ?? 'Erro ao carregar mensagens');
        }
      } else {
        _showErrorSnackBar('Erro de conexão');
      }
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      if (_isInitialLoad) {
        _showErrorSnackBar('Erro ao carregar mensagens');
      }
    } finally {
      if (_isInitialLoad) {
        setState(() {
          isLoading = false;
          _isInitialLoad = false;
        });
      }
    }
  }

  Future<void> _loadMoreMessages() async {
    if (!hasMore || isLoading) return;

    currentOffset += messagesLimit;
    await _loadMessages();
  }

  Future<void> _loadMembers() async {
    setState(() {
      isLoadingMembers = true;
    });

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.groupMembersURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'user_id': widget.userData['id'],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            members = List<Map<String, dynamic>>.from(data['membros'] ?? []);
          });
        } else {
          _showErrorSnackBar(data['message'] ?? 'Erro ao carregar membros');
        }
      }
    } catch (e) {
      print('Erro ao carregar membros: $e');
      _showErrorSnackBar('Erro ao carregar membros');
    } finally {
      setState(() {
        isLoadingMembers = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || isSendingMessage) return;

    setState(() {
      isSendingMessage = true;
    });

    // Adiciona mensagem localmente primeiro (UI responsiva)
    final tempMessage = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'remetente_id': widget.userData['id'],
      'remetente_nome': widget.userData['username'] ?? 'Eu',
      'remetente_photo': widget.userData['photo'],
      'mensagem': message,
      'horario_formatado': _formatTime(DateTime.now()),
      'editada': false,
    };

    setState(() {
      messages.add(tempMessage);
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.sendMessagesGroupURL),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grupo_id': widget.groupId,
          'remetente_id': widget.userData['id'],
          'mensagem': message,
          'tipo': 'texto',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove mensagem temporária e busca mensagens atualizadas
          setState(() {
            messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
          });

          if (data['mensagem'] != null) {
            setState(() {
              messages.add(data['mensagem']);
            });
            _scrollToBottom();
          } else {
            // Se não retornou a mensagem, recarregar todas
            await _fetchNewMessages();
          }
        } else {
          // Remove mensagem temporária em caso de erro
          setState(() {
            messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
          });

          _showErrorSnackBar(data['message'] ?? 'Erro ao enviar mensagem');
          _messageController.text = message;
        }
      } else {
        // Remove mensagem temporária em caso de erro
        setState(() {
          messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
        });

        _showErrorSnackBar('Erro de conexão');
        _messageController.text = message;
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');

      // Remove mensagem temporária em caso de erro
      setState(() {
        messages.removeWhere((msg) => msg['id'] == tempMessage['id']);
      });

      _showErrorSnackBar('Erro ao enviar mensagem');
      _messageController.text = message;
    } finally {
      setState(() {
        isSendingMessage = false;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _scrollToBottom() {
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

  Future<void> _refreshMessages() async {
    await _loadMessages(isRefresh: true);
  }

  void _showGroupDetails() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (context) => _buildGroupDetailsModal(),
    );
  }

  Widget _buildGroupDetailsModal() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.groupPhoto != null
                          ? NetworkImage(widget.groupPhoto!)
                          : null,
                      backgroundColor: Colors.green,
                      child: widget.groupPhoto == null
                          ? Text(
                              widget.groupName.isNotEmpty
                                  ? widget.groupName[0].toUpperCase()
                                  : 'G',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.groupName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${members.length} membros',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Membros
              Expanded(
                child: isLoadingMembers
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return _buildMemberItem(member);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberItem(Map<String, dynamic> member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage:
                member['photo'] != null ? NetworkImage(member['photo']) : null,
            backgroundColor: _getAvatarColor(member['username'] ?? ''),
            child: member['photo'] == null
                ? Text(
                    (member['username'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['username'] ?? 'Usuário',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _getRoleText(member['papel'] ?? 'membro'),
                  style: TextStyle(
                    color: _getRoleColor(member['papel'] ?? 'membro'),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleText(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'moderador':
        return 'Moderador';
      default:
        return 'Membro';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'moderador':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getAvatarColor(String username) {
    final hash = username.hashCode;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _showGroupDetails,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.groupPhoto != null
                    ? NetworkImage(widget.groupPhoto!)
                    : null,
                backgroundColor: Colors.green,
                child: widget.groupPhoto == null
                    ? Text(
                        widget.groupName.isNotEmpty
                            ? widget.groupName[0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.groupName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${members.length} membros',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshMessages,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showGroupDetails,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshMessages,
              child: _isInitialLoad && isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : messages.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma mensagem ainda\nSeja o primeiro a enviar uma mensagem!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: messages.length + (isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Mostrar loading no topo se estiver carregando mais mensagens
                            if (index == 0 &&
                                isLoading &&
                                messages.isNotEmpty &&
                                !_isInitialLoad) {
                              return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                              );
                            }

                            // Ajustar índice se estiver mostrando loading
                            final messageIndex = (isLoading &&
                                    messages.isNotEmpty &&
                                    !_isInitialLoad)
                                ? index - 1
                                : index;
                            final message = messages[messageIndex];
                            final isMe = message['remetente_id']?.toString() ==
                                widget.userData['id']?.toString();

                            return _buildMessageBubble(message, isMe);
                          },
                        ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundImage: message['remetente_photo'] != null
                  ? NetworkImage(message['remetente_photo'])
                  : null,
              backgroundColor: _getAvatarColor(message['remetente_nome'] ?? ''),
              child: message['remetente_photo'] == null
                  ? Text(
                      (message['remetente_nome'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      message['remetente_nome'] ?? 'Usuário',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.green : Colors.grey[800],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message['mensagem'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message['horario_formatado'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          if (message['editada'] == true ||
                              message['editada'] == 1) ...[
                            const SizedBox(width: 4),
                            Text(
                              'editada',
                              style: TextStyle(
                                color: isMe ? Colors.white60 : Colors.grey[500],
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundImage: widget.userData['photo'] != null
                  ? NetworkImage(widget.userData['photo'])
                  : null,
              backgroundColor: Colors.green,
              child: widget.userData['photo'] == null
                  ? Text(
                      (widget.userData['username'] ?? 'U')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(
          top: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Digite uma mensagem...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                enabled: !isSendingMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: isSendingMessage ? Colors.grey : Colors.green,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isSendingMessage ? null : _sendMessage,
              icon: isSendingMessage
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
