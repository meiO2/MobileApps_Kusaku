import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:frontend_kusaku/Widgets/scan_widgets.dart';
import 'package:frontend_kusaku/Navigation/HomePage_Kusaku/transfer_page.dart';

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
  bool _isScanning = false;

  ScanContentType _contentType = ScanContentType.qris;
  String? _selectedGalleryId;
  String? _statusMessage;

  final MobileScannerController _scannerController =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);

  static const List<ScanGalleryItem> _galleryItems = [
    ScanGalleryItem(id: 'qr-1'),
    ScanGalleryItem(id: 'qr-2'),
    ScanGalleryItem(id: 'qr-3'),
    ScanGalleryItem(id: 'qr-4'),
    ScanGalleryItem(id: 'receipt-1', isReceipt: true),
    ScanGalleryItem(id: 'receipt-2', isReceipt: true),
    ScanGalleryItem(id: 'receipt-3', isReceipt: true),
    ScanGalleryItem(id: 'receipt-4', isReceipt: true),
  ];

  String get _previewLabel =>
      _contentType == ScanContentType.receipt ? 'Photo' : 'QRIS';

  String get _headline => _contentType == ScanContentType.receipt
      ? 'Unggah nota untuk diproses'
      : 'Bayar lebih cepat & aman';

  String get _subheadline => _contentType == ScanContentType.receipt
      ? 'Ambil gambar nota atau pilih dari galeri'
      : 'Arahkan kamera ke kode QR';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScanColors.pageBackground,
      body: Stack(
        children: [
          // 🔥 CAMERA BACKGROUND
          if (_contentType == ScanContentType.qris)
            MobileScanner(
              controller: _scannerController,
              onDetect: (BarcodeCapture capture) {
                if (_isScanning) return;
                _isScanning = true;

                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;

                if (code != null) {
                  print("QR RESULT: $code");

                  // contoh navigate
                }
              }
            ),

          // 🔥 UI OVERLAY (UNCHANGED)
          Column(
            children: [
              ScanTopBar(
                title: 'Scan QRIS',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Column(
                  children: [
                    ScanInstructionSection(
                      title: _headline,
                      subtitle: _subheadline,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 340),
                                child: ScanPreviewFrame(
                                  contentType: _contentType,
                                  isFlashOn: _isFlashOn,
                                  showGalleryOverlay: _isGalleryOpen,
                                  previewLabel: _previewLabel,
                                ),
                              ),
                            ),
                          ),
                          if (!_isGalleryOpen) const ScanGuidanceCard(),
                          if (_statusMessage != null && !_isGalleryOpen)
                            ScanStatusChip(label: _statusMessage!),
                        ],
                      ),
                    ),
                    if (!_isGalleryOpen)
                      ScanActionBar(
                        items: [
                          ScanActionItem(
                            label: _isFlashOn
                                ? 'Flash Aktif'
                                : 'Nyalakan\nFlash',
                            icon: Icons.flash_on_rounded,
                            isActive: _isFlashOn,
                            onTap: _isBusy ? () {} : _toggleFlash,
                          ),
                          ScanActionItem(
                            label: _contentType ==
                                    ScanContentType.receipt
                                ? 'Qris'
                                : 'Unggah\nNota',
                            icon: _contentType ==
                                    ScanContentType.receipt
                                ? Icons.qr_code_scanner_rounded
                                : Icons.receipt_long_rounded,
                            onTap: _isBusy
                                ? () {}
                                : _contentType ==
                                        ScanContentType.receipt
                                    ? _openQrisMode
                                    : _openReceiptMode,
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
            ],
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

  // 🔥 QR DETECTION
  void _onQRDetected(String code) async {
    if (_isScanning) return;

    _isScanning = true;

    try {
      print("QR RESULT: $code");

      int? userId;

      // 🔥 support JSON QR
      try {
        final data = jsonDecode(code);
        userId = data['user_id'];
      } catch (_) {
        userId = int.tryParse(code);
      }

      if (userId == null) {
        _showError("QR tidak valid");
        return;
      }

      if (!mounted) return;

    } catch (e) {
      _showError("Gagal scan QR");
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      _isScanning = false;
    }
  }

  void _showError(String message) {
    setState(() {
      _statusMessage = message;
    });
  }

  // 🔦 FLASH
  Future<void> _toggleFlash() async {
    setState(() {
      _isFlashOn = !_isFlashOn;
      _statusMessage = _isFlashOn ? 'Flash aktif' : 'Flash mati';
    });

    _scannerController.toggleTorch();
    await widget.onFlashChanged?.call(_isFlashOn);
  }

  // 🔄 MODE SWITCH
  Future<void> _openReceiptMode() async {
    setState(() {
      _contentType = ScanContentType.receipt;
      _isGalleryOpen = false;
      _statusMessage = 'Mode nota aktif';
    });

    await widget.onContentTypeChanged?.call(_contentType);
  }

  Future<void> _openQrisMode() async {
    setState(() {
      _contentType = ScanContentType.qris;
      _isGalleryOpen = false;
      _statusMessage = 'Mode QRIS aktif';
    });

    await widget.onContentTypeChanged?.call(_contentType);
  }

  // 🖼️ GALLERY
  void _openGallery() {
    setState(() {
      _isGalleryOpen = true;
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

    await widget.onGallerySubmitted?.call(selectedItem);

    setState(() {
      _isGalleryOpen = false;
    });
  }
}