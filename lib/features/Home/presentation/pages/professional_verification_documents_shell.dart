import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/domain/entities/verification_document.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VerificationPickedFile {
  const VerificationPickedFile({
    required this.name,
    required this.mimeType,
    required this.bytes,
  });

  final String name;
  final String mimeType;
  final List<int> bytes;
}

abstract class VerificationDocumentPicker {
  Future<VerificationPickedFile?> pick();
}

class FilePickerVerificationDocumentPicker
    implements VerificationDocumentPicker {
  const FilePickerVerificationDocumentPicker();

  @override
  Future<VerificationPickedFile?> pick() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
      allowMultiple: false,
    );
    final files = result?.files;
    final file = files == null || files.isEmpty ? null : files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null) {
      return null;
    }
    return VerificationPickedFile(
      name: file.name,
      mimeType: _mimeTypeFor(file.name, file.extension),
      bytes: bytes,
    );
  }

  static String _mimeTypeFor(String name, String? extension) {
    final value =
        extension == null || extension.trim().isEmpty
            ? name.split('.').last
            : extension;
    return switch (value.toLowerCase()) {
      'pdf' => 'application/pdf',
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      _ => 'application/octet-stream',
    };
  }
}

class ProfessionalVerificationDocumentsShellPage extends StatefulWidget {
  const ProfessionalVerificationDocumentsShellPage({
    super.key,
    this.verificationRepository,
    this.documentPicker,
  });

  final VerificationRepository? verificationRepository;
  final VerificationDocumentPicker? documentPicker;

  @override
  State<ProfessionalVerificationDocumentsShellPage> createState() =>
      _ProfessionalVerificationDocumentsShellPageState();
}

class _ProfessionalVerificationDocumentsShellPageState
    extends State<ProfessionalVerificationDocumentsShellPage> {
  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  String? _uploadError;
  String? _uploadSuccess;
  String _selectedDocumentType = _documentTypes.first;
  List<VerificationDocument> _documents = const <VerificationDocument>[];

  VerificationRepository get _verificationRepository =>
      widget.verificationRepository ?? sl<VerificationRepository>();
  VerificationDocumentPicker get _documentPicker =>
      widget.documentPicker ?? const FilePickerVerificationDocumentPicker();

  static const int _maxUploadBytes = 10 * 1024 * 1024;
  static const List<String> _documentTypes = <String>[
    'LICENSE',
    'IDENTITY',
    'CERTIFICATION',
  ];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await _verificationRepository.documents();
      if (!mounted) {
        return;
      }
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _safeVerificationError(failure);
        _documents = const <VerificationDocument>[];
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _documents = const <VerificationDocument>[];
        _isLoading = false;
      });
    }
  }

  String _safeVerificationError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration => 'Backend is not configured yet.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

  Future<void> _uploadDocument() async {
    setState(() {
      _uploadError = null;
      _uploadSuccess = null;
    });

    final picked = await _documentPicker.pick();
    if (!mounted) {
      return;
    }
    if (picked == null) {
      setState(() {
        _uploadError = 'No file selected.';
      });
      return;
    }

    final validationError = _validatePickedFile(picked);
    if (validationError != null) {
      setState(() {
        _uploadError = validationError;
      });
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      await _verificationRepository.uploadDocument(
        VerificationUploadRequest(
          documentType: _selectedDocumentType,
          originalFileName: picked.name,
          mimeType: picked.mimeType,
          fileBytes: picked.bytes,
          fileSizeBytes: picked.bytes.length,
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadSuccess = 'Document uploaded and pending review.';
      });
      await _loadDocuments();
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadError = _safeVerificationError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadError = 'Something went wrong. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  String? _validatePickedFile(VerificationPickedFile file) {
    if (file.bytes.isEmpty) {
      return 'Selected file is empty.';
    }
    if (file.bytes.length > _maxUploadBytes) {
      return 'Select a file smaller than 10 MB.';
    }
    if (!_isAllowedMimeType(file.mimeType) ||
        !_hasAllowedExtension(file.name)) {
      return 'Only PDF, JPEG, or PNG files are supported.';
    }
    return null;
  }

  bool _isAllowedMimeType(String mimeType) {
    return const <String>{
      'application/pdf',
      'image/jpeg',
      'image/png',
    }.contains(mimeType.trim().toLowerCase());
  }

  bool _hasAllowedExtension(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return const <String>{'pdf', 'jpg', 'jpeg', 'png'}.contains(extension);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Verification documents',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: _loadDocuments,
          child: ListView(
            padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            children: [
              _IntroCard(onRefresh: _loadDocuments),
              SizedBox(height: 16.h),
              _UploadCard(
                documentTypes: _documentTypes,
                selectedDocumentType: _selectedDocumentType,
                isUploading: _isUploading,
                error: _uploadError,
                success: _uploadSuccess,
                onDocumentTypeChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selectedDocumentType = value;
                    _uploadError = null;
                    _uploadSuccess = null;
                  });
                },
                onUpload: _isUploading ? null : _uploadDocument,
              ),
              SizedBox(height: 16.h),
              if (_isLoading)
                const _StateCard(message: 'Loading verification documents...')
              else if (_error != null)
                _StateCard(message: _error!)
              else if (_documents.isEmpty)
                const _StateCard(
                  message: 'No verification documents are submitted yet.',
                )
              else
                ..._documents.map(
                  (document) => Padding(
                    padding: REdgeInsets.only(bottom: 12.h),
                    child: _DocumentCard(document: document),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Professional verification',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Document status is loaded from your backend account.',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: AppColors.primaryBlue5),
          ),
        ],
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.documentTypes,
    required this.selectedDocumentType,
    required this.isUploading,
    required this.error,
    required this.success,
    required this.onDocumentTypeChanged,
    required this.onUpload,
  });

  final List<String> documentTypes;
  final String selectedDocumentType;
  final bool isUploading;
  final String? error;
  final String? success;
  final ValueChanged<String?> onDocumentTypeChanged;
  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.upload_file, color: AppColors.primaryBlue5),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload document',
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Select one PDF, JPEG, or PNG file under 10 MB.',
                  style: TextStyle(
                    fontSize: FontSizes.footer4,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryBlue11,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  initialValue: selectedDocumentType,
                  decoration: const InputDecoration(
                    labelText: 'Document type',
                    border: OutlineInputBorder(),
                  ),
                  items: documentTypes
                      .map(
                        (type) => DropdownMenuItem<String>(
                          value: type,
                          child: Text(_documentTypeLabel(type)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: isUploading ? null : onDocumentTypeChanged,
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onUpload,
                    icon:
                        isUploading
                            ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                            : const Icon(Icons.upload_file),
                    label: Text(
                      isUploading ? 'Uploading...' : 'Choose file to upload',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue5,
                      foregroundColor: AppColors.kWhite,
                    ),
                  ),
                ),
                if (error != null) ...[
                  SizedBox(height: 10.h),
                  _InlineMessage(message: error!, isError: true),
                ],
                if (success != null) ...[
                  SizedBox(height: 10.h),
                  _InlineMessage(message: success!, isError: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _documentTypeLabel(String value) {
    return value
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _InlineMessage extends StatelessWidget {
  const _InlineMessage({required this.message, required this.isError});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: FontSizes.footer4,
        fontFamily: AppFonts.montserrat,
        fontWeight: FontWeight.w600,
        color: isError ? Colors.redAccent : AppColors.primaryBlue5,
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final VerificationDocument document;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _documentTypeLabel(document.documentType),
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              _StatusPill(status: document.status),
            ],
          ),
          SizedBox(height: 12.h),
          _MetaRow(label: 'Document id', value: document.id),
          _MetaRow(
            label: 'MIME type',
            value: _orUnavailable(document.mimeType),
          ),
          _MetaRow(
            label: 'File size',
            value:
                document.fileSizeBytes == null
                    ? 'Not available'
                    : '${document.fileSizeBytes} bytes',
          ),
          _MetaRow(
            label: 'Checksum',
            value: document.checksumProvided ? 'Provided' : 'Not provided',
          ),
          _MetaRow(
            label: 'Uploaded',
            value:
                document.uploadedAt == null
                    ? 'Not available'
                    : _dateLabel(document.uploadedAt!),
          ),
        ],
      ),
    );
  }

  String _documentTypeLabel(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      return 'Verification document';
    }
    return normalized
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  String _orUnavailable(String value) {
    return value.trim().isEmpty ? 'Not available' : value;
  }

  String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.blue02,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Text(
        status.trim().isEmpty ? 'UNKNOWN' : status.trim().toUpperCase(),
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.kBlack,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 104.w,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryBlue11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
