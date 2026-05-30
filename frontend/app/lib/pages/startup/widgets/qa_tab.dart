// Eduardo Kairalla - 24024241

// Content of the "Q&A" tab on the startup detail screen.

// --- IMPORTS ---
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mesclainvest/app/app_state.dart';
import 'package:mesclainvest/pages/startup/controllers/startup_controller.dart';
import 'package:mesclainvest/pages/startup/models/startup_model.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- WIDGET ---

/// I display the Q&A tab for a startup, including a question list and an input field.
class QATab extends StatefulWidget {
  final StartupController controller;
  final String startupId;

  const QATab({super.key, required this.controller, required this.startupId});

  @override
  State<QATab> createState() => _QATabState();
}

/// State for QATab.
class _QATabState extends State<QATab> {
  final _textController = TextEditingController();
  bool _isPrivate = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  /// I send the typed question to the controller and show a result snackbar.
  Future<void> _sendQuestion() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final canSendPrivate = widget.controller.isInvestor;
    final success = await widget.controller.sendQuestion(
      widget.startupId,
      text,
      _isPrivate && canSendPrivate,
    );

    if (!mounted) return;

    if (success) {
      _textController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pergunta enviada com sucesso!'),
          backgroundColor: Colors.green.shade700,
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
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, i) => _questionCard(questions[i]),
                ),
        ),

        _inputField(isSending),
      ],
    );
  }

  /// I build the empty state view shown when there are no questions yet.
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Nenhuma pergunta ainda.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Seja o primeiro a perguntar!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  /// I build a card displaying a single question, its author, and the answer if available.
  Widget _questionCard(QuestionModel q) {
    final dateFmt = DateFormat('dd/MM/yyyy', 'pt_BR');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
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
              _authorAvatar(q),
              const SizedBox(width: 8),
              Text(
                q.authorName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              if (q.isPrivate) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700.withValues(alpha: 0.12),
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
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            q.text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
              height: 1.4,
            ),
          ),

          if (q.answer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted(context),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(color: AppColors.textPrimary(context), width: 3),
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
                      color: AppColors.textMuted(context),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    q.answer!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
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
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// I build the author avatar circle with a photo or initial fallback.
  Widget _authorAvatar(QuestionModel q) {
    final isMe = q.authorUid != null &&
        q.authorUid == FirebaseAuth.instance.currentUser?.uid;
    final photoUrl = isMe ? AppState.instance.profile?.photoUrl : null;
    final initial = q.authorName.isNotEmpty ? q.authorName[0].toUpperCase() : '?';

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.textPrimary(context),
        shape: BoxShape.circle,
      ),
      child: photoUrl != null
          ? ClipOval(
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.surfaceColor(context),
                    ),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.surfaceColor(context),
                ),
              ),
            ),
    );
  }

  /// I build the question input field with a privacy toggle and send button.
  Widget _inputField(bool isSending) {
    final isInvestor = widget.controller.isInvestor;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
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
          if (isInvestor) ...[
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
                          color: _isPrivate ? AppColors.textPrimary(context) : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _isPrivate
                                ? AppColors.textPrimary(context)
                                : AppColors.border(context),
                          ),
                        ),
                        child: _isPrivate
                            ? Icon(
                                Icons.check,
                                size: 12,
                                color: AppColors.surfaceColor(context),
                              )
                            : null,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Pergunta privada',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  maxLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendQuestion(),
                  style: TextStyle(color: AppColors.textPrimary(context)),
                  decoration: InputDecoration(
                    hintText: 'Faça sua pergunta...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted(context),
                    ),
                    filled: true,
                    fillColor: AppColors.surfaceMuted(context),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
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
                    color: isSending ? AppColors.surfaceMuted(context) : AppColors.textPrimary(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: isSending
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            color: AppColors.surfaceColor(context),
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.send_rounded,
                          color: AppColors.surfaceColor(context),
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
}
