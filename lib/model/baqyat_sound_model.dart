class BaqyatSoundsResponse {
  final bool success;
  final int statusCode;
  final List<BaqyatSoundItem> data;

  BaqyatSoundsResponse({
    required this.success,
    required this.statusCode,
    required this.data,
  });

  factory BaqyatSoundsResponse.fromJson(Map<String, dynamic> json) {
    return BaqyatSoundsResponse(
      success: json['success'] as bool? ?? false,
      statusCode: json['statusCode'] as int? ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => BaqyatSoundItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'statusCode': statusCode,
        'data': data.map((item) => item.toJson()).toList(),
      };
}

class BaqyatSoundItem {
  final int id;
  final String title;
  final List<BaqyatSoundFile> files;

  BaqyatSoundItem({
    required this.id,
    required this.title,
    required this.files,
  });

  factory BaqyatSoundItem.fromJson(Map<String, dynamic> json) {
    return BaqyatSoundItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      files: (json['files'] as List<dynamic>? ?? [])
          .map((file) => BaqyatSoundFile.fromJson(file as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'files': files.map((file) => file.toJson()).toList(),
      };
}

class BaqyatSoundFile {
  final int readerId;
  final String readerName;
  final String picPath;
  final String? path;
  final String? pathM4a;
  final String size;
  final String duration;

  BaqyatSoundFile({
    required this.readerId,
    required this.readerName,
    required this.picPath,
    required this.path,
    required this.pathM4a,
    required this.size,
    required this.duration,
  });

  factory BaqyatSoundFile.fromJson(Map<String, dynamic> json) {
    return BaqyatSoundFile(
      readerId: json['ReaderID'] as int? ?? 0,
      readerName: json['ReaderName'] as String? ?? '',
      picPath: json['picPath'] as String? ?? '',
      path: json['Path'] as String?,
      pathM4a: json['pathM4a'] as String?,
      size: json['size'] as String? ?? '0',
      duration: json['duration'] as String? ?? '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'ReaderID': readerId,
        'ReaderName': readerName,
        'picPath': picPath,
        'Path': path,
        'pathM4a': pathM4a,
        'size': size,
        'duration': duration,
      };
}
