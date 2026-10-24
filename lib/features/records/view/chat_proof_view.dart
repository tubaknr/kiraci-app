import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/record_add_controller.dart';

/// Konuşma / Yazışma Kanıtı Ekranı (Sümeyye - T14)
class ChatProofView extends StatefulWidget {
  final String caseId;
  final RecordAddController controller;
  final VoidCallback? onSuccess;

  const ChatProofView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<ChatProofView> createState() => _ChatProofViewState();
}

class _ChatProofViewState extends State<ChatProofView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String _platform = 'WhatsApp';
  File? _screenshotFile;

  final List<String> _platforms = const [
    'WhatsApp',
    'SMS',
    'E-Posta',
    'Telegram',
    'Diğer',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _screenshotFile = File(picked.path));
      }
    } catch (_) {
      _showSnackbar('Ekran görüntüsü seçilirken bir hata oluştu.');
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_screenshotFile == null) {
      _showSnackbar('Lütfen bir yazışma ekran görüntüsü seçin.');
      return;
    }

    final String finalTitle = _titleController.text.trim().isEmpty
        ? '$_platform Yazışma Kaydı'
        : _titleController.text.trim();

    final String finalNote = _noteController.text.trim().isEmpty
        ? 'Kanal: $_platform'
        : 'Kanal: $_platform\n${_noteController.text.trim()}';

    final bool success = await widget.controller.addFileRecord(
      caseId: widget.caseId,
      type: 'chat',
      title: finalTitle,
      note: finalNote,
      file: _screenshotFile!,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yazışma / İletişim Kanıtı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLegalWarningBanner(),
            const SizedBox(height: 16),
            _buildPlatformSelector(),
            const SizedBox(height: 16),
            _buildImagePickerCard(),
            if (_screenshotFile != null) ...[
              const SizedBox(height: 12),
              _buildImagePreview(),
            ],
            const SizedBox(height: 16),
            _buildInputFields(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hukuki Uyarı & Kişisel Veriler (KVKK)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Color(0xFFB45309),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Karşı tarafın rızası veya bilgisi olmadan alınan kayıtlar TCK m.132-134 kapsamında suç teşkil edebilir. Yalnızca kira ilişkisine ve uyuşmazlığa doğrudan delil oluşturan yazışmaları ekleyin.',
                  style: TextStyle(fontSize: 11, height: 1.4, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'İletişim Kanalı',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _platforms.map((p) {
            final bool isSelected = _platform == p;
            return ChoiceChip(
              label: Text(p),
              selected: isSelected,
              onSelected: (bool selected) {
                if (selected) setState(() => _platform = p);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildImagePickerCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.chat_bubble_outline, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            const Text(
              'Ekran Görüntüsü Yükleyin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text(
              'Mesaj tarih ve saatini gösteren net bir ekran görüntüsü ekleyin.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Galeriden Seç'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto Çek'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ekran görüntüsü hazır: ${_screenshotFile!.path.split('/').last}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _screenshotFile = null),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Başlık (Opsiyonel)',
            hintText: 'Örn: $_platform Kira Artış Talebi Mesajı',
            prefixIcon: const Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Görüşme Özeti / Notlar',
            hintText: 'Mesajın içeriği, kiminle görüşüldüğü ve varılan mutabakat...',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<ViewStatus>(
      valueListenable: widget.controller.status,
      builder: (BuildContext context, ViewStatus status, _) {
        final bool isLoading = status == ViewStatus.loading;
        return ElevatedButton.icon(
          onPressed: isLoading ? null : _submit,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.shield_outlined),
          label: Text(isLoading ? 'Mühürleniyor...' : 'Konuşma Kanıtını Zincire Ekle'),
        );
      },
    );
  }
}
