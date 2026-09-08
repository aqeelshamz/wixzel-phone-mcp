import '../models/knowledge_base.dart';
import '../page.dart';
import '../transport.dart';

/// Knowledge bases: facts and FAQs an agent can draw on.
class KnowledgeBases {
  /// Binds the resource to a transport.
  const KnowledgeBases(this._transport);

  final Transport _transport;

  /// Lists knowledge bases.
  Future<Page<KnowledgeBase>> list(
          {int? limit, String? startingAfter, String? endingBefore}) =>
      _transport.list('/v1/knowledge-bases', KnowledgeBase.fromJson, query: {
        'limit': limit,
        'starting_after': startingAfter,
        'ending_before': endingBefore,
      });

  /// Creates one.
  Future<KnowledgeBase> create(CreateKnowledgeBase body) =>
      _transport.request('POST', '/v1/knowledge-bases', KnowledgeBase.fromJson,
          body: body.toJson());

  /// Fetches one.
  Future<KnowledgeBase> retrieve(String id) => _transport.request('GET',
      '/v1/knowledge-bases/${Uri.encodeComponent(id)}', KnowledgeBase.fromJson);

  /// Changes one. Only the fields you set are changed.
  Future<KnowledgeBase> update(String id, UpdateKnowledgeBase body) =>
      _transport.request(
          'PATCH',
          '/v1/knowledge-bases/${Uri.encodeComponent(id)}',
          KnowledgeBase.fromJson,
          body: body.toJson());

  /// Deletes one.
  Future<void> delete(String id) => _transport.requestVoid(
      'DELETE', '/v1/knowledge-bases/${Uri.encodeComponent(id)}');
}
