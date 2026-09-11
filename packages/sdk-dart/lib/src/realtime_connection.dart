import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'models/realtime.dart';

/// One frame from the server. See the Realtime guide for the protocol.
sealed class RealtimeEvent {
  const RealtimeEvent();

  /// Maps a decoded frame; unknown types become [RealtimeUnknownEvent].
  factory RealtimeEvent.fromJson(Map<String, dynamic> json) {
    switch (json['type']) {
      case 'session.started':
        return RealtimeStarted(
          sessionId: json['session_id'] as String? ?? '',
          callId: json['call_id'] as String? ?? '',
          agentId: json['agent_id'] as String? ?? '',
          engine: json['engine'] as String? ?? '',
          maxDurationSeconds: (json['max_duration_seconds'] as num?)?.toInt() ?? 0,
        );
      case 'audio':
        return RealtimeAudio(base64Decode(json['audio'] as String? ?? ''));
      case 'audio.clear':
        return const RealtimeAudioClear();
      case 'transcript':
        return RealtimeTranscript(
          role: json['role'] as String? ?? 'assistant',
          text: json['text'] as String? ?? '',
        );
      case 'session.warning':
        return RealtimeWarning(
          code: json['code'] as String? ?? '',
          secondsRemaining: (json['seconds_remaining'] as num?)?.toInt(),
        );
      case 'error':
        return RealtimeError(
          code: json['code'] as String? ?? 'unknown',
          message: json['message'] as String? ?? '',
        );
      case 'session.ended':
        return RealtimeEnded(
          reason: json['reason'] as String? ?? 'disconnected',
          durationSeconds: (json['duration_seconds'] as num?)?.toInt() ?? 0,
        );
      default:
        return RealtimeUnknownEvent(json);
    }
  }
}

/// The session was admitted and the agent is connecting.
class RealtimeStarted extends RealtimeEvent {
  /// A started event.
  const RealtimeStarted({
    required this.sessionId,
    required this.callId,
    required this.agentId,
    required this.engine,
    required this.maxDurationSeconds,
  });

  /// The session's id, also the call's `session_id`.
  final String sessionId;

  /// The call this session is logged as.
  final String callId;

  /// The agent.
  final String agentId;

  /// Its voice engine.
  final String engine;

  /// When the server will end it.
  final int maxDurationSeconds;
}

/// Agent speech: raw G.711 µ-law, 8 kHz mono. Decode with [mulawToPcm16].
class RealtimeAudio extends RealtimeEvent {
  /// An audio chunk.
  const RealtimeAudio(this.mulaw);

  /// The µ-law bytes.
  final Uint8List mulaw;
}

/// The user interrupted: drop any agent audio you have queued.
class RealtimeAudioClear extends RealtimeEvent {
  /// A barge-in.
  const RealtimeAudioClear();
}

/// A line of the conversation.
class RealtimeTranscript extends RealtimeEvent {
  /// A transcript line.
  const RealtimeTranscript({required this.role, required this.text});

  /// `user` or `assistant`.
  final String role;

  /// What was said.
  final String text;
}

/// Something worth telling the user, without ending (e.g. `low_balance`).
class RealtimeWarning extends RealtimeEvent {
  /// A warning.
  const RealtimeWarning({required this.code, this.secondsRemaining});

  /// e.g. `low_balance`.
  final String code;

  /// For `low_balance`, roughly how long is left.
  final int? secondsRemaining;
}

/// An error. Before `session.started` it means the session was refused.
class RealtimeError extends RealtimeEvent {
  /// An error.
  const RealtimeError({required this.code, required this.message});

  /// Stable, machine-readable: `insufficient_credits`, `concurrency_limit`, …
  final String code;

  /// For people.
  final String message;
}

/// The session is over.
class RealtimeEnded extends RealtimeEvent {
  /// An end.
  const RealtimeEnded({required this.reason, required this.durationSeconds});

  /// `client`, `agent`, `max_duration`, `idle`, `insufficient_credits`,
  /// `error` or `disconnected`.
  final String reason;

  /// How long it ran, as billed.
  final int durationSeconds;
}

/// A frame type this version does not know.
class RealtimeUnknownEvent extends RealtimeEvent {
  /// An unknown frame.
  const RealtimeUnknownEvent(this.json);

  /// The raw frame.
  final Map<String, dynamic> json;
}

/// A live connection to `wss /v1/realtime`.
///
/// The protocol, without the audio plumbing: send the user's microphone as
/// 20 ms µ-law frames with [sendAudio], play [RealtimeAudio] events, and drop
/// queued playback on [RealtimeAudioClear]. Microphone and speaker access are
/// the app's (on Flutter, a recording and a PCM playback plugin); [pcm16ToMulaw]
/// and [mulawToPcm16] convert between what those give you and the wire.
///
/// ```dart
/// // your server: final session = await wixzel.realtime.createSession(...)
/// final conn = RealtimeConnection.connect(url: session.url, clientSecret: session.clientSecret);
/// conn.events.listen((e) {
///   switch (e) {
///     case RealtimeAudio(:final mulaw): player.add(mulawToPcm16(mulaw));
///     case RealtimeAudioClear(): player.clear();
///     case RealtimeTranscript(:final role, :final text): print('$role: $text');
///     case RealtimeEnded(:final reason): print('ended: $reason');
///     default:
///   }
/// });
/// mic.listen((pcm16) => conn.sendAudio(pcm16ToMulaw(pcm16)));
/// ```
class RealtimeConnection {
  RealtimeConnection._(this._channel) {
    _subscription = _channel.stream.listen(
      (data) {
        if (data is! String) return;
        final Object? decoded;
        try {
          decoded = jsonDecode(data);
        } catch (_) {
          return;
        }
        if (decoded is Map<String, dynamic>) _events.add(RealtimeEvent.fromJson(decoded));
      },
      onDone: () {
        closeCode = _channel.closeCode;
        _events.close();
      },
      onError: (Object e) => _events.addError(e),
    );
  }

  /// Opens the socket with a secret minted by `realtime.createSession`.
  factory RealtimeConnection.connect({required String url, required String clientSecret}) {
    final uri = Uri.parse(url);
    final withSecret = uri.replace(queryParameters: {...uri.queryParameters, 'client_secret': clientSecret});
    return RealtimeConnection._(WebSocketChannel.connect(withSecret));
  }

  /// Opens the socket for a [RealtimeSession] your server passed along.
  factory RealtimeConnection.forSession(RealtimeSession session) =>
      RealtimeConnection.connect(url: session.url, clientSecret: session.clientSecret);

  final WebSocketChannel _channel;
  late final StreamSubscription<dynamic> _subscription;
  final _events = StreamController<RealtimeEvent>.broadcast();

  /// The socket's close code once it has closed: 1000 normally, 44xx for a
  /// refusal (4401 bad secret, 4402 no credit, 4409 at the limit, …).
  int? closeCode;

  /// Every frame from the server, in order.
  Stream<RealtimeEvent> get events => _events.stream;

  /// Resolves when the socket is open.
  Future<void> get ready => _channel.ready;

  /// Sends microphone audio: G.711 µ-law, 8 kHz mono, ideally 160-byte (20 ms) frames.
  void sendAudio(Uint8List mulaw) {
    _channel.sink.add(jsonEncode({'type': 'audio', 'audio': base64Encode(mulaw)}));
  }

  /// Hangs up. The server answers with `session.ended` and closes.
  Future<void> end() async {
    _channel.sink.add(jsonEncode({'type': 'session.end'}));
    await _channel.sink.close();
    await _subscription.cancel();
    if (!_events.isClosed) await _events.close();
  }
}

const int _bias = 0x84;
const int _clip = 32635;

/// 16-bit PCM samples (8 kHz mono) to G.711 µ-law bytes.
Uint8List pcm16ToMulaw(Int16List pcm) {
  final out = Uint8List(pcm.length);
  for (var i = 0; i < pcm.length; i++) {
    var s = pcm[i];
    final sign = (s >> 8) & 0x80;
    if (sign != 0) s = -s;
    if (s > _clip) s = _clip;
    s += _bias;
    var exponent = 7;
    for (var mask = 0x4000; (s & mask) == 0 && exponent > 0; exponent--, mask >>= 1) {}
    final mantissa = (s >> (exponent + 3)) & 0x0f;
    out[i] = ~(sign | (exponent << 4) | mantissa) & 0xff;
  }
  return out;
}

/// G.711 µ-law bytes to 16-bit PCM samples (8 kHz mono).
Int16List mulawToPcm16(Uint8List mulaw) {
  final out = Int16List(mulaw.length);
  for (var i = 0; i < mulaw.length; i++) {
    final u = ~mulaw[i] & 0xff;
    final sign = u & 0x80;
    final exponent = (u >> 4) & 0x07;
    final mantissa = u & 0x0f;
    final sample = (((mantissa << 3) + _bias) << exponent) - _bias;
    out[i] = sign != 0 ? -sample : sample;
  }
  return out;
}
