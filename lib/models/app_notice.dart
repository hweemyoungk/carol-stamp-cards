import 'package:carol/models/int_model.dart';

class AppNotice extends IntModel {
  final String displayName;
  final int priority;
  final String description;
  final bool canSuppress;
  final bool isSuppressed;
  final DateTime? expirationDate;
  final Uri? url;

  AppNotice({
    required super.id,
    required super.isDeleted,
    required this.displayName,
    required this.priority,
    required this.description,
    required this.canSuppress,
    required this.isSuppressed,
    required this.expirationDate,
    required this.url,
  });

  AppNotice.fromJson(Map<String, dynamic> json)
      : displayName = json['displayName'] as String,
        priority = json['priority'] as int,
        description = json['description'] as String,
        canSuppress = json['canSuppress'] as bool,
        isSuppressed = json['isSuppressed'] as bool,
        expirationDate = json['expirationDate'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['expirationDate']),
        url = json['url'] == null ? null : Uri.parse(json['url']),
        super(
          id: json['id'] as int,
          isDeleted: json['isDeleted'] as bool,
        );

  AppNotice copyWith({
    int? id,
    bool? isDeleted,
    String? displayName,
    int? priority,
    String? description,
    bool? canSuppress,
    bool? isSuppressed,
    DateTime? expirationDate,
    Uri? url,
  }) {
    return AppNotice(
      id: id ?? this.id,
      isDeleted: isDeleted ?? this.isDeleted,
      displayName: displayName ?? this.displayName,
      priority: priority ?? this.priority,
      description: description ?? this.description,
      canSuppress: canSuppress ?? this.canSuppress,
      isSuppressed: isSuppressed ?? this.isSuppressed,
      expirationDate: expirationDate ?? this.expirationDate,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isDeleted': isDeleted,
        'displayName': displayName,
        'priority': priority,
        'description': description,
        'canSuppress': canSuppress,
        'isSuppressed': isSuppressed,
        'expirationDate': expirationDate,
        'url': url?.toString(),
      };
}
