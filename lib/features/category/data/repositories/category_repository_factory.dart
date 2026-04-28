import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_data_source.dart';
import 'category_repository_impl.dart';

CategoryRepository createCategoryRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final localDataSource = CategoryLocalDataSource(database.categoryDao);
  return CategoryRepositoryImpl(localDataSource);
}
