/// Eduardo Kairalla - 24024241

/// Content of the "Q&A" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';


// --- WIDGET ---

class QATab extends StatefulWidget {

  final StartupController controller;
  final String startupId;

  const QATab({
    super.key,
    required this.controller,
    required this.startupId,
  });

  @override
  State<QATab> createState() => _QATabState();
}

class _QATabState extends State<QATab> {

  final _textController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendQuestion() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final success = await widget.controller.sendQuestion(
      widget.startupId,
      text,
      _isPrivate,
    );

    if (!mounted) return;

    if (success) {
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pergunta enviada com sucesso!'),
          backgroundColor: Colors.black,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao enviar pergunta. Tente novamente.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.controller.questions;
    final isSending = widget.controller.isSendingQuestion;

    return Column(
      children: [

        Expanded(
          child: questions.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: questions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => _questionCard(questions[i]),
                ),
        ),

        _inputField(isSending),

      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'Nenhuma pergunta ainda.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seja o primeiro a perguntar!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(QuestionModel q) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    q.authorName.isNotEmpty ? q.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                q.authorName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (q.isPrivate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Privada',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                dateFmt.format(q.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            q.text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          if (q.answer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                  left: BorderSide(color: Colors.black, width: 3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resposta do empreendedor',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.black.withValues(alpha: 0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.answer!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withValues(alpha: 0.7),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Aguardando resposta...',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ],

        ],
      ),
    );
  }

  Widget _inputField(bool isSending) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _isPrivate = !_isPrivate),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: _isPrivate ? Colors.black : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: _isPrivate ? Colors.black : Colors.grey.shade400,
                        ),
                      ),
                      child: _isPrivate
                          ? const Icon(Icons.check, size: 12, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Pergunta privada',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendQuestion(),
                  decoration: InputDecoration(
                    hintText: 'Faça sua pergunta...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.35),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: isSending ? null : _sendQuestion,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isSending ? Colors.grey.shade300 : Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isSending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }
}
