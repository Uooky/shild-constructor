import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shild_constructor/features/project/domain/models/project.dart';

class ProjectFileService {
  Future<String> saveProject(Project project) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${project.name.replaceAll(' ', '_')}.shield.json');
    await file.writeAsString(jsonEncode(project.toJson()));
    return file.path;
  }

  Future<Project?> openProject(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    final contents = await file.readAsString();
    final map = jsonDecode(contents) as Map<String, dynamic>;
    return Project.fromJson(map);
  }
}
