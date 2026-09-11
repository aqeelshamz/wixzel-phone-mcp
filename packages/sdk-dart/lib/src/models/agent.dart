import '../json.dart';
import 'voice.dart';

/// A voice agent: a prompt plus a voice engine.
class Agent {
  /// Builds an agent record.
  const Agent({
    required this.id,
    required this.name,
    required this.systemPrompt,
    required this.voice,
    required this.language,
    required this.appointmentBookingEnabled,
    required this.createdAt,
    this.openingMessage,
    this.knowledgeBaseId,
    this.outboundPhoneNumberId,
  });

  /// Parses the API's shape.
  factory Agent.fromJson(Json json) => Agent(
        id: readString(json, 'id'),
        name: readString(json, 'name'),
        systemPrompt: readString(json, 'system_prompt'),
        openingMessage: readStringOrNull(json, 'opening_message'),
        voice: readObject(json, 'voice', VoiceConfig.fromJson) ??
            const VoiceConfig(),
        language: readString(json, 'language'),
        knowledgeBaseId: readStringOrNull(json, 'knowledge_base_id'),
        outboundPhoneNumberId:
            readStringOrNull(json, 'outbound_phone_number_id'),
        appointmentBookingEnabled:
            readBool(json, 'appointment_booking_enabled'),
        createdAt: readDateTimeRequired(json, 'created_at'),
      );

  /// The agent's id.
  final String id;

  /// A label for your own reference.
  final String name;

  /// The agent's instructions. Spoken conversation, so short and concrete.
  final String systemPrompt;

  /// Spoken as soon as the call connects. Supports `{{name}}` merge fields.
  final String? openingMessage;

  /// The voice engine.
  final VoiceConfig voice;

  /// BCP-47 tag for the conversation.
  final String language;

  /// A knowledge base the agent draws on, if any.
  final String? knowledgeBaseId;

  /// Default caller id for outbound calls placed with this agent.
  final String? outboundPhoneNumberId;

  /// Whether the agent may book appointments during a call.
  final bool appointmentBookingEnabled;

  /// When the agent was created. UTC.
  final DateTime createdAt;
}

/// The body of `agents.create`.
class CreateAgent {
  /// Builds a create-agent request.
  const CreateAgent({
    required this.name,
    required this.systemPrompt,
    required this.openingMessage,
    required this.voice,
    this.language,
    this.knowledgeBaseId,
    this.outboundPhoneNumberId,
    this.appointmentBookingEnabled,
  });

  /// A label for your own reference.
  final String name;

  /// The agent's instructions.
  final String systemPrompt;

  /// Spoken as soon as the call connects. Required: an agent without one
  /// answers in silence.
  final String openingMessage;

  /// The voice engine. Pick models from `engines.list()`.
  final VoiceConfig voice;

  /// BCP-47 tag for the conversation.
  final String? language;

  /// A knowledge base the agent may draw on.
  final String? knowledgeBaseId;

  /// Default caller id for outbound calls.
  final String? outboundPhoneNumberId;

  /// Let the agent book appointments during a call.
  final bool? appointmentBookingEnabled;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'system_prompt': systemPrompt,
        'opening_message': openingMessage,
        'voice': voice.toJson(),
        'language': language,
        'knowledge_base_id': knowledgeBaseId,
        'outbound_phone_number_id': outboundPhoneNumberId,
        'appointment_booking_enabled': appointmentBookingEnabled,
      });
}

/// The body of `agents.update`. Only the fields you set are changed.
class UpdateAgent {
  /// Builds a partial update.
  const UpdateAgent({
    this.name,
    this.systemPrompt,
    this.openingMessage,
    this.voice,
    this.language,
    this.knowledgeBaseId,
    this.outboundPhoneNumberId,
    this.appointmentBookingEnabled,
  });

  /// A label for your own reference.
  final String? name;

  /// The agent's instructions.
  final String? systemPrompt;

  /// Spoken as soon as the call connects.
  final String? openingMessage;

  /// The voice engine. Sending this replaces the whole object.
  final VoiceConfig? voice;

  /// BCP-47 tag for the conversation.
  final String? language;

  /// A knowledge base the agent may draw on.
  final String? knowledgeBaseId;

  /// Default caller id for outbound calls.
  final String? outboundPhoneNumberId;

  /// Whether the agent may book appointments.
  final bool? appointmentBookingEnabled;

  /// The API's shape, without the nulls.
  Json toJson() => omitNulls({
        'name': name,
        'system_prompt': systemPrompt,
        'opening_message': openingMessage,
        'voice': voice?.toJson(),
        'language': language,
        'knowledge_base_id': knowledgeBaseId,
        'outbound_phone_number_id': outboundPhoneNumberId,
        'appointment_booking_enabled': appointmentBookingEnabled,
      });
}

/// A test call: ring a number and have the agent speak one phrase.
///
/// A probe, not a conversation. It answers "is the trunk configured and does
/// this agent sound right" in seconds, and it rings a real phone and spends
/// real credit doing it.
class TestCall {
  /// Builds a test-call request.
  const TestCall({
    required this.to,
    this.fromNumberId,
    this.phrase,
  });

  /// Destination in E.164 form, e.g. `+14155551234`. A real phone rings.
  final String to;

  /// Defaults to the agent's own outbound number.
  final String? fromNumberId;

  /// What to say. Defaults to the agent's opening message, which is usually
  /// what you want to hear.
  final String? phrase;

  /// The API's wire shape.
  Json toJson() => omitNulls({
        'to': to,
        'from_number_id': fromNumberId,
        'phrase': phrase,
      });
}
