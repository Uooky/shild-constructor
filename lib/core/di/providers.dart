import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shild_constructor/core/database/app_database.dart';
import 'package:shild_constructor/features/project/data/project_file_service.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) => AppDatabase());
final projectFileServiceProvider = Provider<ProjectFileService>((ref) => ProjectFileService());
