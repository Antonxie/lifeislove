import 'package:flutter/material.dart';
import '../../../core/models/message_model.dart';

class ChatInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, MessageType) onSendMessage;
  final VoidCallback onSendImage;
  final VoidCallback onSendVoice;
  final VoidCallback onSendFile;

  const ChatInput({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    required this.onSendImage,
    required this.onSendVoice,
    required this.onSendFile,
  }) : super(key: key);

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  bool _isRecording = false;
  bool _showAttachments = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_showAttachments) _buildAttachmentOptions(theme),
          Row(
            children: [
              // Attachment button
              IconButton(
                icon: Icon(
                  _showAttachments ? Icons.close : Icons.add,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () {
                  setState(() {
                    _showAttachments = !_showAttachments;
                  });
                },
              ),
              
              // Text input
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: widget.controller,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: '输入消息...',
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        widget.onSendMessage(text, MessageType.text);
                      }
                    },
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Voice/Send button
              GestureDetector(
                onTap: () {
                  if (widget.controller.text.trim().isNotEmpty) {
                    widget.onSendMessage(widget.controller.text, MessageType.text);
                  } else {
                    widget.onSendVoice();
                  }
                },
                onLongPressStart: (_) {
                  if (widget.controller.text.trim().isEmpty) {
                    setState(() {
                      _isRecording = true;
                    });
                    // Start voice recording
                  }
                },
                onLongPressEnd: (_) {
                  if (_isRecording) {
                    setState(() {
                      _isRecording = false;
                    });
                    // Stop voice recording and send
                    widget.onSendVoice();
                  }
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? Colors.red 
                        : theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.controller.text.trim().isNotEmpty
                        ? Icons.send
                        : (_isRecording ? Icons.stop : Icons.mic),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentOption(
            theme,
            Icons.photo_outlined,
            '照片',
            Colors.blue,
            widget.onSendImage,
          ),
          _buildAttachmentOption(
            theme,
            Icons.videocam_outlined,
            '视频',
            Colors.green,
            () {
              // TODO: Implement video picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('视频发送功能开发中...')),
              );
            },
          ),
          _buildAttachmentOption(
            theme,
            Icons.attach_file_outlined,
            '文件',
            Colors.orange,
            widget.onSendFile,
          ),
          _buildAttachmentOption(
            theme,
            Icons.location_on_outlined,
            '位置',
            Colors.red,
            () {
              // TODO: Implement location picker
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('位置发送功能开发中...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
    ThemeData theme,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAttachments = false;
        });
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}