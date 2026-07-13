import 'package:app_t/core/constants/app_colors.dart';
import 'package:app_t/core/constants/fonts.dart';
import 'package:app_t/core/constants/navigators/routeName.dart';
import 'package:app_t/core/theme/textStyle.dart';
import 'package:app_t/features/Home/presentation/state/qa_local_store.dart';
import 'package:app_t/shared/widgets/carenet_button.dart';
import 'package:app_t/shared/widgets/carenet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QaCommentRouteArgs {
  const QaCommentRouteArgs({required this.questionId});

  final String questionId;
}

class QaShellPage extends StatelessWidget {
  const QaShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: SafeArea(
        child: Padding(
          padding: REdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AbsorbPointer(
                      child: CarenetTextField(
                        hintText: 'What do you want to ask or share?',
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: CarenetButton(
                      label: 'Ask',
                      onPressed: () {
                        Navigator.pushNamed(context, RouteName.qAAsk);
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: CarenetButton(
                      label: 'Answer',
                      type: CarenetButtonType.outline,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteName.qAAnswerRequests,
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                'Q&A feed',
                style: TextStyle(
                  fontSize: FontSizes.body2,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w700,
                  color: AppColors.kBlack,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This Q&A lane is local for now: asking and answering work inside the app, while deeper matching, moderation, and account sync can plug in later.',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ValueListenableBuilder<List<QaQuestion>>(
                  valueListenable: QaLocalStore.questions,
                  builder: (context, questions, _) {
                    return ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return ValueListenableBuilder<Set<String>>(
                          valueListenable: QaLocalStore.followedAuthors,
                          builder: (context, followedAuthors, __) {
                            final question = questions[index];
                            final isFollowing = followedAuthors.contains(
                              question.author,
                            );
                            return _QaQuestionCard(
                              question: question,
                              isFollowing: isFollowing,
                              onFollowToggle:
                                  () => QaLocalStore.toggleFollow(
                                    question.author,
                                  ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QaAskPage extends StatefulWidget {
  const QaAskPage({super.key});

  @override
  State<QaAskPage> createState() => _QaAskPageState();
}

class _QaAskPageState extends State<QaAskPage> {
  static const List<String> _privacyOptions = <String>['Public', 'Private'];

  final TextEditingController _questionController = TextEditingController();
  String? _selectedPrivacy = 'Public';
  String? _questionError;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _questionController.text.trim();
    final questionError = text.isEmpty ? 'Question is required' : null;
    final startsCorrectly =
        text.startsWith('What') ||
        text.startsWith('How') ||
        text.startsWith('Why') ||
        text.startsWith('Where');
    final prefixError =
        text.isNotEmpty && !startsCorrectly
            ? 'Start with What, How, Why, or Where'
            : null;

    setState(() {
      _questionError = questionError ?? prefixError;
    });

    if (_questionError != null) {
      return;
    }

    QaLocalStore.addQuestion(
      question: text,
      privacy: _selectedPrivacy ?? 'Public',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        centerTitle: true,
        title: Text(
          'Ask Q&A',
          style: TextStyle(
            fontSize: FontSizes.footer2,
            fontFamily: AppFonts.montserrat,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryBlue5,
          ),
        ),
        actions: [
          Padding(
            padding: REdgeInsets.only(right: 16.w),
            child: Center(
              child: TextButton(
                onPressed: _submit,
                child: Text(
                  'Send',
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: REdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start your question with What, How, Why, or Where.',
                style: TextStyle(
                  fontSize: FontSizes.footer3,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _privacyOptions.map((privacy) {
                      final isSelected = _selectedPrivacy == privacy;
                      return ChoiceChip(
                        label: Text(privacy),
                        selected: isSelected,
                        selectedColor: AppColors.primaryBlue7,
                        backgroundColor: AppColors.blue02,
                        labelStyle: TextStyle(
                          fontFamily: AppFonts.montserrat,
                          fontWeight: FontWeight.w500,
                          fontSize: FontSizes.footer4,
                          color:
                              isSelected
                                  ? AppColors.primaryBlue5
                                  : AppColors.kBlack,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedPrivacy = privacy;
                          });
                        },
                      );
                    }).toList(),
              ),
              SizedBox(height: 16.h),
              CarenetTextField(
                label: 'Question',
                hintText: 'What do you want to ask?',
                controller: _questionController,
                onChanged: (_) => setState(() => _questionError = null),
                validationState:
                    _questionError == null
                        ? CarenetTextFieldValidationState.none
                        : CarenetTextFieldValidationState.invalid,
                errorText: _questionError,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QaAnswerRequestsPage extends StatelessWidget {
  const QaAnswerRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Answer requests',
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
        child: Padding(
          padding: REdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ValueListenableBuilder<List<QaAnswerDraft>>(
                  valueListenable: QaLocalStore.answerDrafts,
                  builder: (context, drafts, _) {
                    if (drafts.isEmpty) {
                      return Container(
                        padding: REdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.white04),
                        ),
                        child: Center(
                          child: Text(
                            'No answer drafts',
                            style: TextStyle(
                              fontSize: FontSizes.body2,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryBlue11,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: drafts.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final draft = drafts[index];
                        return Container(
                          padding: REdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.kWhite,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.white04),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                draft.question,
                                style: TextStyle(
                                  fontSize: FontSizes.footer2,
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.kBlack,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                draft.answer,
                                style: TextStyle(
                                  fontSize: FontSizes.footer3,
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.primaryBlue11,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                draft.savedAtLabel,
                                style: TextStyle(
                                  fontSize: FontSizes.footer4,
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 16.h),
              CarenetButton(
                label: 'See tagged questions for you',
                onPressed: () {
                  Navigator.pushNamed(context, RouteName.qAAnswerForYou);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QaAnswerForYouPage extends StatelessWidget {
  const QaAnswerForYouPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Tagged questions',
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
        child: Padding(
          padding: REdgeInsets.all(16.r),
          child: ValueListenableBuilder<List<QaQuestion>>(
            valueListenable: QaLocalStore.questions,
            builder: (context, _, __) {
              return ValueListenableBuilder<Set<String>>(
                valueListenable: QaLocalStore.followedAuthors,
                builder: (context, followedAuthors, ___) {
                  return ValueListenableBuilder<Set<String>>(
                    valueListenable: QaLocalStore.bookmarkedQuestionIds,
                    builder: (context, bookmarkedIds, ____) {
                      return ValueListenableBuilder<Set<String>>(
                        valueListenable: QaLocalStore.passedQuestionIds,
                        builder: (context, __, _____) {
                          final taggedQuestions =
                              QaLocalStore.taggedQuestions();

                          if (taggedQuestions.isEmpty) {
                            return Center(
                              child: Text(
                                'No tagged questions left',
                                style: TextStyle(
                                  fontSize: FontSizes.body2,
                                  fontFamily: AppFonts.montserrat,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryBlue11,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: taggedQuestions.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              final question = taggedQuestions[index];
                              return _QaAnswerCard(
                                question: question,
                                isFollowing: followedAuthors.contains(
                                  question.author,
                                ),
                                isBookmarked: bookmarkedIds.contains(
                                  question.id,
                                ),
                                onFollowToggle:
                                    () => QaLocalStore.toggleFollow(
                                      question.author,
                                    ),
                                onBookmarkToggle:
                                    () => QaLocalStore.toggleBookmark(
                                      question.id,
                                    ),
                                onPass:
                                    () =>
                                        QaLocalStore.passQuestion(question.id),
                                onAnswer: () {
                                  Navigator.pushNamed(
                                    context,
                                    RouteName.commentAnswer,
                                    arguments: QaCommentRouteArgs(
                                      questionId: question.id,
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class QaCommentAnswerPage extends StatefulWidget {
  const QaCommentAnswerPage({super.key, required this.questionId});

  final String questionId;

  @override
  State<QaCommentAnswerPage> createState() => _QaCommentAnswerPageState();
}

class _QaCommentAnswerPageState extends State<QaCommentAnswerPage> {
  final TextEditingController _answerController = TextEditingController();
  String? _answerError;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _answerController.text.trim();
    setState(() {
      _answerError = text.isEmpty ? 'Answer is required' : null;
    });
    if (_answerError != null) {
      return;
    }

    QaLocalStore.addAnswer(questionId: widget.questionId, answer: text);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final question = QaLocalStore.questions.value.firstWhere(
      (entry) => entry.id == widget.questionId,
    );

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          'Comment',
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: REdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: QaLocalStore.followedAuthors,
                      builder: (context, followedAuthors, _) {
                        return _QaQuestionCard(
                          question: question,
                          isFollowing: followedAuthors.contains(
                            question.author,
                          ),
                          onFollowToggle:
                              () => QaLocalStore.toggleFollow(question.author),
                        );
                      },
                    ),
                    Text(
                      'Local answers',
                      style: TextStyle(
                        fontSize: FontSizes.footer2,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w700,
                        color: AppColors.kBlack,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ValueListenableBuilder<Map<String, List<String>>>(
                      valueListenable: QaLocalStore.answersByQuestionId,
                      builder: (context, _, __) {
                        final answers = QaLocalStore.answersForQuestion(
                          question.id,
                        );
                        if (answers.isEmpty) {
                          return Text(
                            'No answers yet',
                            style: TextStyle(
                              fontSize: FontSizes.footer3,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryBlue11,
                            ),
                          );
                        }

                        return Column(
                          children:
                              answers.map((answer) {
                                return Container(
                                  width: double.infinity,
                                  margin: REdgeInsets.only(bottom: 10.h),
                                  padding: REdgeInsets.all(14.r),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: AppColors.white04,
                                    ),
                                  ),
                                  child: Text(
                                    answer,
                                    style: TextStyle(
                                      fontSize: FontSizes.footer3,
                                      fontFamily: AppFonts.montserrat,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.kBlack,
                                      height: 1.4,
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: REdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
              decoration: BoxDecoration(
                color: AppColors.kWhite,
                border: Border(top: BorderSide(color: AppColors.white04)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CarenetTextField(
                      hintText: 'What do you think?',
                      controller: _answerController,
                      onChanged: (_) => setState(() => _answerError = null),
                      validationState:
                          _answerError == null
                              ? CarenetTextFieldValidationState.none
                              : CarenetTextFieldValidationState.invalid,
                      errorText: _answerError,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  IconButton(
                    onPressed: _submit,
                    icon: Icon(
                      Icons.send_outlined,
                      color: AppColors.primaryBlue5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QaAnswerCard extends StatelessWidget {
  const _QaAnswerCard({
    required this.question,
    required this.isFollowing,
    required this.isBookmarked,
    required this.onFollowToggle,
    required this.onBookmarkToggle,
    required this.onPass,
    required this.onAnswer,
  });

  final QaQuestion question;
  final bool isFollowing;
  final bool isBookmarked;
  final VoidCallback onFollowToggle;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onPass;
  final VoidCallback onAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: REdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.white04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  question.author,
                  style: TextStyle(
                    fontSize: FontSizes.footer2,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kBlack,
                  ),
                ),
              ),
              Text(
                question.timeLabel,
                style: TextStyle(
                  fontSize: FontSizes.footer4,
                  fontFamily: AppFonts.montserrat,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primaryBlue11,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            question.question,
            style: TextStyle(
              fontSize: FontSizes.body2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No answer yet',
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: onAnswer,
                  child: const Text('Answer'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: onBookmarkToggle,
                  child: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: onFollowToggle,
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
              ),
              Expanded(
                child: TextButton(onPressed: onPass, child: const Text('Pass')),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QaQuestionCard extends StatelessWidget {
  const _QaQuestionCard({
    required this.question,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  final QaQuestion question;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: REdgeInsets.only(bottom: 16.h),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: AppColors.primaryBlue5,
                child: Text(
                  question.author.characters.first,
                  style: TextStyle(
                    fontSize: FontSizes.footer3,
                    fontFamily: AppFonts.montserrat,
                    fontWeight: FontWeight.w700,
                    color: AppColors.kWhite,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            question.author,
                            style: TextStyle(
                              fontSize: FontSizes.footer2,
                              fontFamily: AppFonts.montserrat,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kBlack,
                            ),
                          ),
                        ),
                        Text(
                          question.timeLabel,
                          style: TextStyle(
                            fontSize: FontSizes.footer4,
                            fontFamily: AppFonts.montserrat,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primaryBlue11,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      question.authorLine,
                      style: TextStyle(
                        fontSize: FontSizes.footer4,
                        fontFamily: AppFonts.montserrat,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primaryBlue11,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              SizedBox(
                width: 92.w,
                child: CarenetButton(
                  label: isFollowing ? 'Following' : 'Follow',
                  onPressed: onFollowToggle,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            question.question,
            style: TextStyle(
              fontSize: FontSizes.body2,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w700,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            question.preview,
            style: TextStyle(
              fontSize: FontSizes.footer3,
              fontFamily: AppFonts.montserrat,
              fontWeight: FontWeight.w400,
              color: AppColors.primaryBlue11,
              height: 1.4,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(
                Icons.favorite_border,
                color: AppColors.primaryBlue11,
                size: 18.r,
              ),
              SizedBox(width: 4.w),
              Text(question.likesLabel),
              SizedBox(width: 16.w),
              Icon(
                Icons.chat_bubble_outline,
                color: AppColors.primaryBlue11,
                size: 18.r,
              ),
              SizedBox(width: 4.w),
              Text(question.repliesLabel),
            ],
          ),
          if (question.isLocalDraft) ...[
            SizedBox(height: 10.h),
            Text(
              'Saved locally',
              style: TextStyle(
                fontSize: FontSizes.footer4,
                fontFamily: AppFonts.montserrat,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
