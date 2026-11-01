import 'package:shild_constructor/features/project/domain/models/project.dart';

class VersionService {
  List<ProjectVersion> createVersion({
    required List<ProjectVersion> versions,
    required String comment,
    required bool isAutomatic,
    required String snapshotJson,
  }) {
    final list = [...versions];
    list.add(
      ProjectVersion(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        label: 'v${list.length + 1}',
        comment: comment,
        isAutomatic: isAutomatic,
        createdAt: DateTime.now(),
        snapshotJson: snapshotJson,
      ),
    );

    return list.length > 25 ? list.sublist(list.length - 25) : list;
  }
}
