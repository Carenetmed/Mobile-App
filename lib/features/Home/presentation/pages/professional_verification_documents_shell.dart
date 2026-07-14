import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/di/injection.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Authentication/domain/entities/auth_failure.dart';
import 'package:app_t/features/Home/data/repositories/verification_repository.dart';
import 'package:app_t/features/Home/domain/entities/verification_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfessionalVerificationDocumentsShellPage extends StatefulWidget {
  const ProfessionalVerificationDocumentsShellPage({
    super.key,
    this.verificationRepository,
  });

  final VerificationRepository? verificationRepository;

  @override
  State<ProfessionalVerificationDocumentsShellPage> createState() =>
      _ProfessionalVerificationDocumentsShellPageState();
}

class _ProfessionalVerificationDocumentsShellPageState
    extends State<ProfessionalVerificationDocumentsShellPage> {
  bool _isLoading = true;
  String? _error;
  List<VerificationDocument> _documents = const <VerificationDocument>[];

  VerificationRepository get _verificationRepository =>
      widget.verificationRepository ?? sl<VerificationRepository>();

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
              _UploadDeferredCard(),
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

class _UploadDeferredCard extends StatelessWidget {
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
          const Icon(Icons.lock_outline, color: AppColors.primaryBlue5),
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
                  'Upload UI needs the file picker and retry flow slice.',
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
        ],
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
