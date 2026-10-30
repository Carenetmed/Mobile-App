import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/presentation/carenet_presentation.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/onboarding_repository.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/domain/entities/account_readiness.dart';
import 'package:app_t/features/Home/domain/entities/onboarding_catalog.dart';
import 'package:app_t/features/Home/domain/entities/verification_document.dart';
import 'package:app_t/features/Home/domain/entities/verification_upload_request.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
    this.onboardingRepository,
    this.documentPicker,
  });

  final VerificationRepository? verificationRepository;
  final OnboardingRepository? onboardingRepository;
  final VerificationDocumentPicker? documentPicker;

  @override
  State<ProfessionalVerificationDocumentsShellPage> createState() =>
      _ProfessionalVerificationDocumentsShellPageState();
}

class _ProfessionalVerificationDocumentsShellPageState
    extends State<ProfessionalVerificationDocumentsShellPage> {
  bool _isLoading = true;
  bool _hasLoadedDocuments = false;
  Future<void>? _documentsRequest;
  Future<void>? _readinessRequest;
  bool _isUploading = false;
  bool _isPicking = false;
  double _uploadProgress = 0;
  VerificationUploadController? _uploadController;
  String? _error;
  String? _readinessError;
  String? _uploadError;
  String? _uploadSuccess;
  String _selectedDocumentType = _documentTypes.first;
  List<VerificationDocument> _documents = const <VerificationDocument>[];
  AccountReadiness? _readiness;
  OnboardingCatalog? _catalog;

  VerificationRepository get _verificationRepository =>
      widget.verificationRepository ?? sl<VerificationRepository>();
  OnboardingRepository get _onboardingRepository =>
      widget.onboardingRepository ?? sl<OnboardingRepository>();
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
    _loadReadiness();
    _loadDocuments();
  }

  @override
  void dispose() {
    _uploadController?.cancel();
    super.dispose();
  }

  Future<void> _loadReadiness() async {
    if (!mounted) return;
    final active = _readinessRequest;
    if (active != null) return active;
    final request = _performLoadReadiness();
    _readinessRequest = request;
    try {
      await request;
    } finally {
      if (identical(_readinessRequest, request)) _readinessRequest = null;
    }
  }

  Future<void> _performLoadReadiness() async {
    setState(() {
      _readinessError = null;
    });

    try {
      final catalog = await _onboardingRepository.onboardingCatalog();
      final readiness = await _onboardingRepository.accountReadiness();
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = catalog;
        _readiness = readiness;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _readinessError = _safeVerificationError(failure);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _readinessError =
            'Could not load verification requirements. Please try again.';
      });
    }
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;
    final active = _documentsRequest;
    if (active != null) return active;
    final request = _performLoadDocuments();
    _documentsRequest = request;
    try {
      await request;
    } finally {
      if (identical(_documentsRequest, request)) _documentsRequest = null;
    }
  }

  Future<void> _refresh() async {
    await Future.wait([_loadReadiness(), _loadDocuments()]);
  }

  Future<void> _performLoadDocuments() async {
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
        _hasLoadedDocuments = true;
        _isLoading = false;
      });
    } on AuthFailure catch (failure) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = _safeVerificationError(failure);
        if (failure.type == AuthFailureType.unauthorized ||
            failure.type == AuthFailureType.forbidden) {
          _documents = const <VerificationDocument>[];
          _hasLoadedDocuments = false;
        }
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  String _safeVerificationError(AuthFailure failure) {
    return switch (failure.type) {
      AuthFailureType.missingConfiguration =>
        'Verification is unavailable right now. Please try again.',
      AuthFailureType.unauthorized => 'Please sign in again.',
      AuthFailureType.forbidden => 'This account cannot manage verification.',
      AuthFailureType.validation => 'Please check the details and try again.',
      AuthFailureType.server ||
      AuthFailureType.network => 'Service is unavailable. Please try again.',
      AuthFailureType.invalidCredentials ||
      AuthFailureType.unknown => 'Something went wrong. Please try again.',
    };
  }

  Future<void> _uploadDocument() async {
    if (!mounted || _isUploading) return;
    final uploadController = VerificationUploadController();
    final documentType = _selectedDocumentType;
    _uploadController = uploadController;
    setState(() {
      _isUploading = true;
      _isPicking = true;
      _uploadProgress = 0;
      _uploadError = null;
      _uploadSuccess = null;
    });

    try {
      final picked = await _documentPicker.pick();
      if (!mounted) return;
      setState(() => _isPicking = false);
      if (uploadController.isCancelled) {
        throw const VerificationUploadCancelled();
      }
      if (picked == null) {
        setState(() => _uploadError = 'No file selected.');
        return;
      }
      final validationError = _validatePickedFile(picked);
      if (validationError != null) {
        setState(() => _uploadError = validationError);
        return;
      }
      await _verificationRepository.uploadDocument(
        VerificationUploadRequest(
          documentType: documentType,
          originalFileName: picked.name,
          mimeType: picked.mimeType,
          fileBytes: picked.bytes,
          fileSizeBytes: picked.bytes.length,
          controller: uploadController,
          onProgress: (progress) {
            if (!mounted || _uploadController != uploadController) {
              return;
            }
            setState(() {
              _uploadProgress = progress;
            });
          },
        ),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadSuccess = 'Document uploaded and pending review.';
      });
      // A read started before the upload cannot confirm its resulting state.
      final pendingDocuments = _documentsRequest;
      final pendingReadiness = _readinessRequest;
      await Future.wait([
        if (pendingDocuments != null) pendingDocuments,
        if (pendingReadiness != null) pendingReadiness,
      ]);
      if (!mounted) return;
      await _refresh();
    } on VerificationUploadCancelled {
      if (!mounted) {
        return;
      }
      setState(() {
        _uploadError = 'Upload cancelled.';
      });
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
          _isPicking = false;
          _uploadProgress = 0;
          _uploadController = null;
        });
      }
    }
  }

  void _cancelUpload() {
    _uploadController?.cancel();
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
          onRefresh: _refresh,
          child: ListView(
            padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
            children: [
              _IntroCard(onRefresh: _refresh),
              SizedBox(height: 16.h),
              _VerificationReadinessCard(
                readiness: _readiness,
                catalog: _catalog,
                error: _readinessError,
              ),
              SizedBox(height: 16.h),
              _UploadCard(
                documentTypes: _documentTypes,
                selectedDocumentType: _selectedDocumentType,
                isUploading: _isUploading,
                isPicking: _isPicking,
                uploadProgress: _uploadProgress,
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
                onCancel: _isUploading ? _cancelUpload : null,
              ),
              SizedBox(height: 16.h),
              if (_isLoading && !_hasLoadedDocuments)
                const _StateCard(message: 'Loading verification documents...')
              else if (_isLoading)
                const LinearProgressIndicator(),
              if (_error != null) _StateCard(message: _error!),
              if (_hasLoadedDocuments && _documents.isEmpty)
                const _StateCard(
                  message: 'No verification documents are submitted yet.',
                ),
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
                  'View the current status of your verification documents.',
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
    required this.isPicking,
    required this.uploadProgress,
    required this.error,
    required this.success,
    required this.onDocumentTypeChanged,
    required this.onUpload,
    required this.onCancel,
  });

  final List<String> documentTypes;
  final String selectedDocumentType;
  final bool isUploading;
  final bool isPicking;
  final double uploadProgress;
  final String? error;
  final String? success;
  final ValueChanged<String?> onDocumentTypeChanged;
  final VoidCallback? onUpload;
  final VoidCallback? onCancel;

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
                  isExpanded: true,
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
                      isPicking
                          ? 'Choosing file...'
                          : isUploading
                          ? 'Uploading...'
                          : 'Choose file to upload',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue5,
                      foregroundColor: AppColors.kWhite,
                    ),
                  ),
                ),
                if (isUploading) ...[
                  SizedBox(height: 10.h),
                  if (!isPicking)
                    Semantics(
                      label: 'Document upload progress',
                      value: '${(uploadProgress * 100).round()} percent',
                      child: LinearProgressIndicator(value: uploadProgress),
                    ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (isPicking)
                        const Spacer()
                      else
                        Expanded(
                          child: Text(
                            '${(uploadProgress * 100).round()}% uploaded',
                            style: TextStyle(
                              fontSize: FontSizes.footer4,
                              fontFamily: AppFonts.montserrat,
                              color: AppColors.primaryBlue11,
                            ),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancel upload'),
                      ),
                    ],
                  ),
                ],
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

class _VerificationReadinessCard extends StatelessWidget {
  const _VerificationReadinessCard({
    required this.readiness,
    required this.catalog,
    required this.error,
  });

  final AccountReadiness? readiness;
  final OnboardingCatalog? catalog;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final professional = readiness?.professional;
    final evidence = professional?.requiredEvidence ?? const <String>[];
    final missing = professional?.missingEvidence ?? const <String>[];
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
          Text(
            'Verification readiness',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _statusCopy(readiness, error),
            style: TextStyle(
              fontSize: FontSizes.footer4,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          if (evidence.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              'Required evidence',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w700,
                color: AppColors.kBlack,
              ),
            ),
            SizedBox(height: 8.h),
            ...evidence.map(
              (code) => _EvidenceRow(
                label: _evidenceLabel(code, catalog),
                isMissing: missing.contains(code),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusCopy(AccountReadiness? readiness, String? error) {
    if (error != null) {
      return '$error Pull to refresh before uploading more documents.';
    }
    final professional = readiness?.professional;
    if (professional == null) {
      return 'Checking what you need for verification.';
    }
    if (professional.requiredProfileFields.isNotEmpty) {
      return 'Complete your professional profile before document review.';
    }
    if (professional.missingEvidence.isNotEmpty) {
      return '${professional.missingEvidence.length} required evidence item${professional.missingEvidence.length == 1 ? '' : 's'} still need upload.';
    }
    return switch (professional.verificationStatus.toUpperCase()) {
      'PENDING' => 'Your documents are uploaded and waiting for review.',
      'REJECTED' =>
        'Your verification needs attention. Review the required evidence and upload corrected documents.',
      'VERIFIED' => 'Your professional account is verified.',
      _ =>
        'Your required evidence is uploaded. CareNet will review it before public verification.',
    };
  }

  static String _evidenceLabel(String code, OnboardingCatalog? catalog) {
    final evidenceTypes =
        catalog?.verificationEvidenceTypes ??
        const <VerificationEvidenceType>[];
    for (final evidence in evidenceTypes) {
      if (evidence.code == code) {
        return evidence.label;
      }
    }
    return code
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0]}${part.substring(1).toLowerCase()}')
        .join(' ');
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({required this.label, required this.isMissing});

  final String label;
  final bool isMissing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            isMissing ? Icons.error_outline : Icons.check_circle_outline,
            size: 18.r,
            color: isMissing ? Colors.orangeAccent : AppColors.primaryBlue5,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '${isMissing ? 'Missing' : 'Received'}: $label',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
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
          _MetaRow(
            label: 'File type',
            value: _fileTypeLabel(document.mimeType),
          ),
          _MetaRow(
            label: 'File size',
            value: _fileSizeLabel(document.fileSizeBytes),
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

  String _fileTypeLabel(String value) {
    final mimeType = value.trim().toLowerCase().split(';').first;
    return switch (mimeType) {
      'application/pdf' => 'PDF document',
      'image/jpeg' => 'JPEG image',
      'image/png' => 'PNG image',
      _ => 'File type unavailable',
    };
  }

  String _fileSizeLabel(int? bytes) {
    if (bytes == null || bytes < 0) {
      return 'Not available';
    }
    if (bytes < 1024) {
      return '$bytes bytes';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).round()} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return DateFormat('d MMM y', CareNetPresentation.dateLocale).format(local);
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
        status.trim().isEmpty ? 'Status unavailable' : _statusLabel(status),
        style: TextStyle(
          fontSize: FontSizes.footer4,
          fontFamily: AppFonts.montserrat,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryBlue5,
        ),
      ),
    );
  }

  String _statusLabel(String value) {
    return value
        .trim()
        .split(RegExp(r'[_\s-]+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final compactText =
        MediaQuery.textScalerOf(context).scale(1) > 1.5 ||
        MediaQuery.sizeOf(context).width < 340;
    return Padding(
      padding: REdgeInsets.only(bottom: 8.h),
      child:
          compactText
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue11,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    value,
                    softWrap: true,
                    style: TextStyle(
                      fontSize: FontSizes.footer4,
                      fontFamily: AppFonts.montserrat,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kBlack,
                    ),
                  ),
                ],
              )
              : Row(
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
