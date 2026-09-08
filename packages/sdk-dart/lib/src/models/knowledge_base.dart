import '../json.dart';

/// A question an agent can answer verbatim.
class KnowledgeBaseFaq {
  /// Builds a question and answer pair.
  const KnowledgeBaseFaq({required this.question, required this.answer});

  /// Parses the API's shape.
  factory KnowledgeBaseFaq.fromJson(Json json) => KnowledgeBaseFaq(
        question: readString(json, 'question'),
        answer: readString(json, 'answer'),
      );

  /// What a caller might ask.
  final String question;

  /// What the agent should say.
  final String answer;

  /// The API's shape.
  Json toJson() => {'question': question, 'answer': answer};
}

/// Facts and FAQs an agent draws on during calls.
class KnowledgeBase {
  /// Builds a knowledge base record.
  const KnowledgeBase({
    required this.id,
    required this.name,
    required this.faqs,
    required this.createdAt,
    this.description,
    this.basicInfo,
    this.otherInfo,
  });

  /// Parses the API's shape.
  factory KnowledgeBase.fromJson(Json json) => KnowledgeBase(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        description: readStringOrNull(json, 'description'),
        basicInfo: readStringOrNull(json, 'basic_info'),
        faqs: readList(json, 'faqs', KnowledgeBaseFaq.fromJson),
        otherInfo: readStringOrNull(json, 'other_info'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The knowledge base's id.
  final String id;

  /// A label for your own reference.
  final String name;

  /// What it covers.
  final String? description;

  /// Free text the agent should know: hours, address, pricing, policies.
  final String? basicInfo;

  /// Questions the agent can answer verbatim.
  final List<KnowledgeBaseFaq> faqs;

  /// Anything else.
  final String? otherInfo;

  /// When it was created. UTC.
  final DateTime createdAt;
}

/// The body of `knowledgeBases.create`.
class CreateKnowledgeBase {
  /// Builds a create request.
  const CreateKnowledgeBase({
    required this.name,
    this.description,
    this.basicInfo,
    this.faqs,
    this.otherInfo,
  });

  /// A label for your own reference.
  final String name;

  /// What it covers.
  final String? description;

  /// Free text the agent should know.
  final String? basicInfo;

  /// Questions the agent can answer verbatim.
  final List<KnowledgeBaseFaq>? faqs;

  /// Anything else.
  final String? otherInfo;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'description': description,
        'basic_info': basicInfo,
        'faqs': faqs?.map((f) => f.toJson()).toList(),
        'other_info': otherInfo,
      });
}

/// The body of `knowledgeBases.update`. Only the fields you set are changed;
/// sending [faqs] replaces the whole list.
class UpdateKnowledgeBase {
  /// Builds a partial update.
  const UpdateKnowledgeBase({
    this.name,
    this.description,
    this.basicInfo,
    this.faqs,
    this.otherInfo,
  });

  /// A label for your own reference.
  final String? name;

  /// What it covers.
  final String? description;

  /// Free text the agent should know.
  final String? basicInfo;

  /// Questions the agent can answer verbatim. Replaces the whole list.
  final List<KnowledgeBaseFaq>? faqs;

  /// Anything else.
  final String? otherInfo;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'description': description,
        'basic_info': basicInfo,
        'faqs': faqs?.map((f) => f.toJson()).toList(),
        'other_info': otherInfo,
      });
}
