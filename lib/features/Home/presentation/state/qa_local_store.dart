import 'package:flutter/foundation.dart';

@immutable
class QaQuestion {
  const QaQuestion({
    required this.id,
    required this.author,
    required this.authorLine,
    required this.timeLabel,
    required this.question,
    required this.preview,
    required this.likesLabel,
    required this.repliesLabel,
    this.isTaggedForYou = false,
    this.isLocalDraft = false,
  });

  final String id;
  final String author;
  final String authorLine;
  final String timeLabel;
  final String question;
  final String preview;
  final String likesLabel;
  final String repliesLabel;
  final bool isTaggedForYou;
  final bool isLocalDraft;
}

@immutable
class QaAnswerDraft {
  const QaAnswerDraft({
    required this.questionId,
    required this.question,
    required this.answer,
    required this.savedAtLabel,
  });

  final String questionId;
  final String question;
  final String answer;
  final String savedAtLabel;
}

class QaLocalStore {
  QaLocalStore._();

  static final ValueNotifier<List<QaQuestion>>
  questions = ValueNotifier<List<QaQuestion>>(<QaQuestion>[
    const QaQuestion(
      id: 'qa-1',
      author: 'Lagbaja Tamedu',
      authorLine: 'Posted by John Doe',
      timeLabel: '2 hr',
      question: 'Should men treat prostate cancer?',
      preview:
          'Learn about prostate cancer. Prostate cancer is mostly common in men. Understanding it can save your life or someone you love. Once you are 40 plus, start checking it by visiting your doctor.',
      likesLabel: '22k',
      repliesLabel: '252k',
      isTaggedForYou: true,
    ),
    const QaQuestion(
      id: 'qa-2',
      author: 'Amina Balogun',
      authorLine: 'Posted by Dr. Bello',
      timeLabel: '4 hr',
      question: 'What helps keep blood sugar routines consistent?',
      preview:
          'Looking for practical tips that fit a busy schedule without becoming overwhelming after a few days.',
      likesLabel: '9k',
      repliesLabel: '84 replies',
      isTaggedForYou: true,
    ),
  ]);

  static final ValueNotifier<Set<String>> followedAuthors =
      ValueNotifier<Set<String>>(<String>{});
  static final ValueNotifier<Set<String>> bookmarkedQuestionIds =
      ValueNotifier<Set<String>>(<String>{});
  static final ValueNotifier<Set<String>> passedQuestionIds =
      ValueNotifier<Set<String>>(<String>{});
  static final ValueNotifier<Map<String, List<String>>> answersByQuestionId =
      ValueNotifier<Map<String, List<String>>>(<String, List<String>>{});
  static final ValueNotifier<List<QaAnswerDraft>> answerDrafts =
      ValueNotifier<List<QaAnswerDraft>>(<QaAnswerDraft>[]);

  static void toggleFollow(String author) {
    final next = Set<String>.from(followedAuthors.value);
    if (!next.add(author)) {
      next.remove(author);
    }
    followedAuthors.value = next;
  }

  static void toggleBookmark(String questionId) {
    final next = Set<String>.from(bookmarkedQuestionIds.value);
    if (!next.add(questionId)) {
      next.remove(questionId);
    }
    bookmarkedQuestionIds.value = next;
  }

  static void passQuestion(String questionId) {
    passedQuestionIds.value = <String>{...passedQuestionIds.value, questionId};
  }

  static void addQuestion({required String question, required String privacy}) {
    final normalized = question.trim();
    if (normalized.isEmpty) {
      return;
    }

    final nextQuestion = QaQuestion(
      id: 'qa-local-${questions.value.length + 1}',
      author: 'You',
      authorLine: '$privacy question',
      timeLabel: 'Just now',
      question: normalized,
      preview:
          'Saved locally from the Q&A ask flow. Answer threads, recommendations, and moderation can connect later without changing the route flow.',
      likesLabel: '0',
      repliesLabel: 'No answers yet',
      isLocalDraft: true,
    );

    questions.value = <QaQuestion>[nextQuestion, ...questions.value];
  }

  static List<QaQuestion> taggedQuestions() {
    return questions.value
        .where(
          (question) =>
              question.isTaggedForYou &&
              !passedQuestionIds.value.contains(question.id),
        )
        .toList();
  }

  static List<String> answersForQuestion(String questionId) {
    return answersByQuestionId.value[questionId] ?? const <String>[];
  }

  static void addAnswer({required String questionId, required String answer}) {
    final normalized = answer.trim();
    if (normalized.isEmpty) {
      return;
    }

    final question = questions.value.firstWhere(
      (entry) => entry.id == questionId,
      orElse:
          () => const QaQuestion(
            id: '',
            author: 'Unknown',
            authorLine: '',
            timeLabel: '',
            question: '',
            preview: '',
            likesLabel: '0',
            repliesLabel: 'No answers yet',
          ),
    );
    if (question.id.isEmpty) {
      return;
    }

    final answerMap = Map<String, List<String>>.from(answersByQuestionId.value);
    final existingAnswers = List<String>.from(
      answerMap[questionId] ?? const [],
    );
    existingAnswers.add(normalized);
    answerMap[questionId] = existingAnswers;
    answersByQuestionId.value = answerMap;

    answerDrafts.value = <QaAnswerDraft>[
      QaAnswerDraft(
        questionId: question.id,
        question: question.question,
        answer: normalized,
        savedAtLabel: 'Saved locally',
      ),
      ...answerDrafts.value.where((draft) => draft.questionId != questionId),
    ];
  }

  static void reset() {
    followedAuthors.value = <String>{};
    bookmarkedQuestionIds.value = <String>{};
    passedQuestionIds.value = <String>{};
    answersByQuestionId.value = <String, List<String>>{};
    answerDrafts.value = <QaAnswerDraft>[];
    questions.value = <QaQuestion>[
      const QaQuestion(
        id: 'qa-1',
        author: 'Lagbaja Tamedu',
        authorLine: 'Posted by John Doe',
        timeLabel: '2 hr',
        question: 'Should men treat prostate cancer?',
        preview:
            'Learn about prostate cancer. Prostate cancer is mostly common in men. Understanding it can save your life or someone you love. Once you are 40 plus, start checking it by visiting your doctor.',
        likesLabel: '22k',
        repliesLabel: '252k',
        isTaggedForYou: true,
      ),
      const QaQuestion(
        id: 'qa-2',
        author: 'Amina Balogun',
        authorLine: 'Posted by Dr. Bello',
        timeLabel: '4 hr',
        question: 'What helps keep blood sugar routines consistent?',
        preview:
            'Looking for practical tips that fit a busy schedule without becoming overwhelming after a few days.',
        likesLabel: '9k',
        repliesLabel: '84 replies',
        isTaggedForYou: true,
      ),
    ];
  }
}
