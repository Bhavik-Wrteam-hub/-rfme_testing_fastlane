class FaqsModel {
  FaqsModel({
    this.id,
    this.question,
    this.answer,
    this.translatedQuestion,
    this.translatedAnswer,
  });

  FaqsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    question = json['question']?.toString() ?? '';
    translatedQuestion = json['translated_question']?.toString() ?? '';
    answer = json['answer']?.toString() ?? '';
    translatedAnswer = json['translated_answer']?.toString() ?? '';
  }
  int? id;
  String? question;
  String? translatedQuestion;
  String? answer;
  String? translatedAnswer;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['question'] = question;
    data['translated_question'] = translatedQuestion;
    data['answer'] = answer;
    data['translated_answer'] = translatedAnswer;
    return data;
  }

  FaqsModel copyWith({
    int? id,
    String? question,
    String? answer,
    String? translatedQuestion,
    String? translatedAnswer,
  }) => FaqsModel(
    id: id ?? this.id,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    translatedQuestion: translatedQuestion ?? this.translatedQuestion,
    translatedAnswer: translatedAnswer ?? this.translatedAnswer,
  );
}
