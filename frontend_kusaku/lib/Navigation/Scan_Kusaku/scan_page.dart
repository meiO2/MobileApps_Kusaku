import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Widgets/scan_widgets.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({
    super.key,
    this.onFlashChanged,
    this.onGallerySubmitted,
    this.onContentTypeChanged,
  });

  final Future<void> Function(bool isFlashOn)? onFlashChanged;
  final Future<void> Function(ScanGalleryItem item)? onGallerySubmitted;
  final Future<void> Function(ScanContentType type)? onContentTypeChanged;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _isFlashOn = false;
  bool _isGalleryOpen = false;
  bool _isBusy = false;
  ScanContentType _contentType = ScanContentType.qris;
  String? _selectedGalleryId;
  String? _statusMessage;

  static const List<ScanGalleryItem> _galleryItems = [
    ScanGalleryItem(id: 'qr-1'),
    ScanGalleryItem(id: 'qr-2'),
    ScanGalleryItem(id: 'qr-3'),
    ScanGalleryItem(id: 'qr-4'),
    ScanGalleryItem(id: 'receipt-1', isReceipt: true),
    ScanGalleryItem(id: 'receipt-2', isReceipt: true),
    ScanGalleryItem(id: 'receipt-3', isReceipt: true),
    ScanGalleryItem(id: 'receipt-4', isReceipt: true),
    ScanGalleryItem(id: 'qr-5'),
    ScanGalleryItem(id: 'qr-6'),
    ScanGalleryItem(id: 'receipt-5', isReceipt: true),
    ScanGalleryItem(id: 'receipt-6', isReceipt: true),
    ScanGalleryItem(id: 'qr-7'),
    ScanGalleryItem(id: 'qr-8'),
    ScanGalleryItem(id: 'receipt-7', isReceipt: true),
    ScanGalleryItem(id: 'receipt-8', isReceipt: true),
  ];

  String get _previewLabel {
    return _contentType == ScanContentType.receipt ? 'Photo' : 'QRIS';
  }

  String get _headline {
    return _contentType == ScanContentType.receipt
        ? 'Unggah nota untuk diproses'
        : 'Bayar lebih cepat & aman';
  }

  String get _subheadline {
    return _contentType == ScanContentType.receipt
        ? 'Ambil gambar nota atau pilih dari galeri'
        : 'Arahkan kamera ke kode QR';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScanColors.pageBackground,
      body: Column(
        children: [
          ScanTopBar(
            title: 'Scan QRIS',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScanInstructionSection(
                    title: _headline,
                    subtitle: _subheadline,
                  ),
                  ScanPreviewFrame(
                    contentType: _contentType,
                    isFlashOn: _isFlashOn,
                    showGalleryOverlay: _isGalleryOpen,
                    previewLabel: _previewLabel,
                  ),
                  if (!_isGalleryOpen) const ScanGuidanceCard(),
                  if (_statusMessage != null && !_isGalleryOpen)
                    ScanStatusChip(label: _statusMessage!),
                  if (!_isGalleryOpen)
                    ScanActionBar(
                      items: [
                        ScanActionItem(
                          label: _isFlashOn ? 'Flash Aktif' : 'Nyalakan\nFlash',
                          icon: Icons.flash_on_rounded,
                          isActive: _isFlashOn,
                          onTap: _isBusy ? () {} : _toggleFlash,
                        ),
                        ScanActionItem(
                          label: 'Unggah\nNota',
                          icon: Icons.receipt_long_rounded,
                          onTap: _isBusy ? () {} : _openReceiptMode,
                        ),
                        ScanActionItem(
                          label: 'Upload Dari\nGaleri',
                          icon: Icons.image_outlined,
                          onTap: _isBusy ? () {} : _openGallery,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _isGalleryOpen
          ? GalleryPickerSheet(
              items: _galleryItems,
              selectedId: _selectedGalleryId,
              onSelect: _selectGalleryItem,
              onSend: _isBusy ? () {} : _sendGallerySelection,
            )
          : null,
    );
  }

  Future<void> _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _isBusy = true;
      _statusMessage = _isFlashOn
          ? 'Flash siap digunakan saat kamera backend dihubungkan'
          : 'Flash dimatikan';
    });

    try {
      await widget.onFlashChanged?.call(_isFlashOn);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _openReceiptMode() async {
    setState(() {
      _contentType = ScanContentType.receipt;
      _isGalleryOpen = false;
      _isBusy = true;
      _statusMessage = 'Mode nota aktif. Siap untuk OCR atau upload backend.';
    });

    try {
      await widget.onContentTypeChanged?.call(_contentType);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _openGallery() {
    setState(() {
      _isGalleryOpen = true;
      _statusMessage = null;
      _selectedGalleryId ??= _galleryItems.first.id;
    });
  }

  void _selectGalleryItem(ScanGalleryItem item) {
    setState(() {
      _selectedGalleryId = item.id;
    });
  }

  Future<void> _sendGallerySelection() async {
    final selectedItem = _galleryItems.firstWhere(
      (item) => item.id == _selectedGalleryId,
      orElse: () => _galleryItems.first,
    );

    setState(() {
      _contentType =
          selectedItem.isReceipt ? ScanContentType.receipt : ScanContentType.qris;
      _isBusy = true;
      _statusMessage = selectedItem.isReceipt
          ? 'File galeri dipilih. Siap dikirim ke endpoint upload nota.'
          : 'QR dari galeri dipilih. Siap diproses scanner backend.';
    });

    try {
      await widget.onContentTypeChanged?.call(_contentType);
      await widget.onGallerySubmitted?.call(selectedItem);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _isGalleryOpen = false;
        });
      }
    }
  }
}
