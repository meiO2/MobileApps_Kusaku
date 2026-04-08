import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

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
  bool _isBusy = false;
  bool _isScanning = false;

  ScanContentType _contentType = ScanContentType.qris;
  String? _selectedGalleryId;
  String? _statusMessage;

  final ImagePicker _picker = ImagePicker();
  final BarcodeScanner _barcodeScanner = BarcodeScanner();

  final ms.MobileScannerController _scannerController =
      ms.MobileScannerController(
        detectionSpeed: ms.DetectionSpeed.noDuplicates,
        facing: ms.CameraFacing.back,
      );

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
  void dispose() {
    _scannerController.dispose();
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScanColors.pageBackground,
      body: Stack(
        children: [
          // 🔥 CAMERA BACKGROUND
          if (_contentType == ScanContentType.qris)
            ms.MobileScanner(
              controller: _scannerController,
              onDetect: (ms.BarcodeCapture capture) {
                if (_isScanning) return;
                _isScanning = true;

                final barcode = capture.barcodes.first;
                final code = barcode.rawValue;

                if (code != null) {
                  print("QR RESULT: $code");
                  _onQRDetected(code); // Memanggil fungsi deteksi
                }
              }
            ),

          // 🔥 UI OVERLAY
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
                          // BAGIAN KOTAK TENGAH DIHAPUS DI SINI
                          const Expanded(
                            child: SizedBox.shrink(), // Memberikan ruang kosong agar kamera terlihat jelas
                          ),
                          const ScanGuidanceCard(),
                          if (_statusMessage != null)
                            ScanStatusChip(label: _statusMessage!),
                        ],
                      ),
                    ),
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
      bottomSheet: null,
    );
  }

  // 🔥 QR DETECTION
  void _onQRDetected(String code) async {
    try {
      print("QR RESULT: $code");
      int? userId;
      try {
        final data = jsonDecode(code);
        userId = data['user_id'];
      } catch (_) {
        userId = int.tryParse(code);
      }

      if (userId == null) {
        _showError("QR tidak valid");
      } else {
        // Logika navigasi bisa ditaruh di sini
      }
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
      _statusMessage = 'Mode nota aktif';
    });

    await widget.onContentTypeChanged?.call(_contentType);
  }

  Future<void> _openQrisMode() async {
    setState(() {
      _contentType = ScanContentType.qris;
      _statusMessage = 'Mode QRIS aktif';
    });

    await widget.onContentTypeChanged?.call(_contentType);
  }

  // 🖼️ GALLERY
  Future<void> _openGallery() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
      _statusMessage = 'Membuka galeri...';
    });

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        setState(() {
          _statusMessage = 'Pemilihan gambar dibatalkan';
        });
        return;
      }

      final inputImage = InputImage.fromFilePath(image.path);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      String? qrValue;
      for (final barcode in barcodes) {
        final rawValue = barcode.rawValue;
        if (rawValue != null && rawValue.isNotEmpty) {
          qrValue = rawValue;
          break;
        }
      }

      if (qrValue == null) {
        setState(() {
          _statusMessage = 'QR tidak ditemukan di gambar';
        });
        return;
      }

      setState(() {
        _statusMessage = 'QR dari galeri terdeteksi';
      });

      await widget.onGallerySubmitted?.call(const ScanGalleryItem(id: 'gallery-upload'));
      _onQRDetected(qrValue);
    } catch (_) {
      setState(() {
        _statusMessage = 'Gagal membaca gambar dari galeri';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }
}