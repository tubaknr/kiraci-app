import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/record_add_controller.dart';

/// Kayıt Ekle Ekranı (Sümeyye - T09)
class RecordAddView extends StatefulWidget {
  final String caseId;
  final RecordAddController controller;
  final String? correctsRecordId;
  final VoidCallback? onSuccess;

  const RecordAddView({
    super.key,
    required this.caseId,
    required this.controller,
    this.correctsRecordId,
    this.onSuccess,
  });

  @override
  State<RecordAddView> createState() => _RecordAddViewState();
}

class _RecordAddViewState extends State<RecordAddView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedType = 'document';
  File? _selectedFile;
  String? _selectedFileName;
  int? _selectedFileSize;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        _setPickedFile(File(photo.path), 'photo');
      }
    } catch (e) {
      _showSnackbar('Kamera açılırken bir hata oluştu.');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _setPickedFile(File(image.path), 'photo');
      }
    } catch (e) {
      _showSnackbar('Galeri açılırken bir hata oluştu.');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final List<PlatformFile> files = await FilePicker.pickFiles();
      if (files.isNotEmpty && files.first.path != null) {
        _setPickedFile(File(files.first.path!), _selectedType);
      }
    } catch (e) {
      _showSnackbar('Dosya seçici açılırken bir hata oluştu.');
    }
  }

  void _setPickedFile(File file, String inferredType) {
    setState(() {
      _selectedFile = file;
      _selectedFileName = file.path.split('/').last;
      _selectedFileSize = file.existsSync() ? file.lengthSync() : 0;
      if (_selectedType == 'document' && inferredType == 'photo') {
        _selectedType = 'photo';
      }
    });
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (_selectedFile == null) {
      _showSnackbar('Lütfen bir delil/belge dosyası seçin veya foto çekin.');
      return;
    }

    final bool success = await widget.controller.addFileRecord(
      caseId: widget.caseId,
      type: _selectedType,
      title: _titleController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      file: _selectedFile!,
      correctsRecordId: widget.correctsRecordId,
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
        title: Text(
          widget.correctsRecordId != null ? 'Düzeltme Kaydı Ekle' : 'Yeni Delil / Belge Ekle',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTypeSelector(),
            const SizedBox(height: 16),
            _buildFilePickerSection(),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              _buildSelectedFilePreview(),
            ],
            const SizedBox(height: 16),
            _buildFormFields(),
            const SizedBox(height: 16),
            _buildIntegrityNotice(),
            const SizedBox(height: 16),
            _buildErrorMessage(),
            const SizedBox(height: 8),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kayıt Türü',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypeChip('document', 'Belge', Icons.description_outlined),
            _buildTypeChip('photo', 'Fotoğraf', Icons.photo_camera_outlined),
            _buildTypeChip('video', 'Video', Icons.videocam_outlined),
            _buildTypeChip('audio', 'Ses Kaydı', Icons.mic_outlined),
            _buildTypeChip('chat', 'Yazışma Kanıtı', Icons.chat_outlined),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon) {
    final bool isSelected = _selectedType == type;
    return ChoiceChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      onSelected: (bool selected) {
        if (selected) setState(() => _selectedType = type);
      },
    );
  }

  Widget _buildFilePickerSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Delil Dosyası',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromCamera,
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Foto Çek'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galeri'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDocument,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Dosya'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedFilePreview() {
    final String sizeKb = ((_selectedFileSize ?? 0) / 1024).toStringAsFixed(1);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFileName ?? 'Seçilen Dosya',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Boyut: $sizeKb KB • SHA-256 hesaplanmaya hazır',
                  style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() {
              _selectedFile = null;
              _selectedFileName = null;
              _selectedFileSize = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Kayıt Başlığı *',
            hintText: 'Örn: Daire Teslim Öncesi Duvar Çatlakları',
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Açıklama / Not (Opsiyonel)',
            hintText: 'Delile veya duruma dair ek bilgiler, tanıklar, saat ayrıntıları...',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }

  Widget _buildIntegrityNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_clock_outlined, size: 20, color: AppColors.secondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Eklenen dosya uygulama dizinine kopyalanarak SHA-256 ile özetlenir ve zincire eklenir. Cihaz saati referans alınır.',
              style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.controller.errorMessage,
      builder: (BuildContext context, String? error, _) {
        if (error == null || error.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
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
          label: Text(isLoading ? 'Özetleniyor...' : 'Delil Zincirine Mühürle'),
        );
      },
    );
  }
}
