/// Keys stored in [CustomActivity.enabledFields] and log payloads.
abstract final class LogFieldKind {
  static const title = 'title';
  static const note = 'note';
  static const number = 'number';
  static const duration = 'duration';
  static const tags = 'tags';

  static const all = [title, note, number, duration, tags];

  static String label(String kind) => switch (kind) {
    title => 'Title',
    note => 'Notes',
    number => 'Amount / count',
    duration => 'Duration (minutes)',
    tags => 'Tags',
    _ => kind,
  };
}
