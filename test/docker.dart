import 'dart:io';

import 'package:docker_process/containers/postgres.dart';
import 'package:test/test.dart';

const _kContainerName = 'postgres-dart-test';

void usePostgresDocker() {
  bool isGithubAction() => Platform.environment.containsKey('GITHUB_ACTION');

  setUpAll(() async {
    if (isGithubAction()) {
      // Postgres already running
      return;
    }

    final isRunning = await _isPostgresContainerRunning();
    if (isRunning) {
      return;
    }

    await startPostgres(
      name: _kContainerName,
      version: 'latest',
      pgPort: 5432,
      pgDatabase: 'dart_test',
      pgUser: 'dart',
      pgPassword: 'dart',
      cleanup: true,
    );
  });

  tearDownAll(() async {
    if (isGithubAction()) {
      return;
    }
    await Process.run('docker', ['stop', _kContainerName]);
  });
}

Future<bool> _isPostgresContainerRunning() async {
  final pr = await Process.run(
    'docker',
    ['ps', '--format', '{{.Names}}'],
  );
  return pr.stdout
      .toString()
      .split('\n')
      .map((s) => s.trim())
      .contains(_kContainerName);
}
