import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;

import 'package:frontend_kusaku/Widgets/scan_widgets.dart';
import 'package:frontend_kusaku/config/api_config.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_models.dart';
import 'package:frontend_kusaku/Transaction_confimation/payment_confirmation_page.dart';

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
  static const String _demoQrisNumber = '011006081106';

  bool _isFlashOn = false;
  bool _isBusy = false;
  bool _isScanning = false;

  ScanContentType _contentType = ScanContentType.qris;
  String? _statusMessage;

  final ImagePicker _picker = ImagePicker();

  final ms.MobileScannerController _scannerController =
      ms.MobileScannerController(
        detectionSpeed: ms.DetectionSpeed.noDuplicates,
        facing: ms.CameraFacing.back,
      );

  String get _headline => _contentType == ScanContentType.receipt
      ? 'Unggah nota untuk diproses'
      : 'Bayar lebih cepat & aman';

  String get _subheadline => _contentType == ScanContentType.receipt
      ? 'Ambil gambar nota atau pilih dari galeri'
      : 'Arahkan kamera ke kode QR';

  @override
  void dispose() {
    _scannerController.dispose();
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
      final qrisNumber = code.trim();
      if (qrisNumber.isEmpty) {
        _showError('QR tidak valid');
        return;
      }

      setState(() {
        _isBusy = true;
        _statusMessage = 'Memverifikasi QRIS...';
      });

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}qr/scan/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'qris_number': qrisNumber}),
      );

      final dynamic payload = response.body.isEmpty
          ? null
          : jsonDecode(response.body);
      final body = payload is Map<String, dynamic>
          ? payload
          : <String, dynamic>{};

      if (response.statusCode == 200) {
        await _openPaymentConfirmation(body);
      } else {
        _showError(
          (body['error'] ?? body['detail'] ?? 'QRIS tidak valid atau tidak terdaftar').toString(),
        );
      }
    } catch (e) {
      _showError('Gagal scan QR');
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
      await Future.delayed(const Duration(seconds: 2));
      _isScanning = false;
    }
  }

  int _parseAmount(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final normalized = value.replaceAll(',', '.');
      final decimalValue = double.tryParse(normalized);
      if (decimalValue != null) return decimalValue.round();
    }
    return 0;
  }

  Future<void> _openPaymentConfirmation(Map<String, dynamic> body) async {
    final amount = _parseAmount(body['amount']);
    final transactionDate = DateTime.tryParse((body['transaction_date'] ?? '').toString()) ?? DateTime.now();

    final data = PaymentConfirmationData(
      transactionId: (body['id'] ?? body['qris_number'] ?? '').toString(),
      methodType: PaymentMethodType.qris,
      methodLabel: 'Pembayaran Qris',
      amount: amount,
      transactionFee: 0,
      remainingBalance: _parseAmount(body['remaining_balance']),
      merchant: PaymentMerchantInfo(
        name: (body['merchant_name'] ?? 'Merchant').toString(),
        accountName: (body['merchant_PT'] ?? '-').toString(),
        transactedAt: transactionDate,
      ),
      categories: const [
        PaymentCategoryData(
          id: 'food-drink',
          name: 'Makan & Minum',
          remainingAmount: 0,
          icon: Icons.fastfood_rounded,
        ),
      ],
    );

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PaymentConfirmationPage(data: data)),
    );
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

      final barcodeCaptureCompleter = Completer<ms.BarcodeCapture>();
      final barcodeSubscription = _scannerController.barcodes.listen((capture) {
        if (!barcodeCaptureCompleter.isCompleted && capture.barcodes.isNotEmpty) {
          barcodeCaptureCompleter.complete(capture);
        }
      });

      final found = await _scannerController.analyzeImage(image.path);

      String? qrValue;
      try {
        if (found) {
          final barcodeCapture = await barcodeCaptureCompleter.future.timeout(
            const Duration(seconds: 3),
          );
          qrValue = barcodeCapture.barcodes.first.rawValue;
        }
      } finally {
        await barcodeSubscription.cancel();
      }

      if (qrValue == null) {
        setState(() {
          _statusMessage = 'QR tidak terdeteksi, menggunakan QRIS demo';
        });

        _isScanning = true;
        _onQRDetected(_demoQrisNumber);
        return;
      }

      setState(() {
        _statusMessage = 'QR dari galeri terdeteksi';
      });

      await widget.onGallerySubmitted?.call(const ScanGalleryItem(id: 'gallery-upload'));
      _isScanning = true;
      _onQRDetected(qrValue);
    } catch (_) {
      setState(() {
        _statusMessage = 'Gagal membaca gambar, menggunakan QRIS demo';
      });

      _isScanning = true;
      _onQRDetected(_demoQrisNumber);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }
}