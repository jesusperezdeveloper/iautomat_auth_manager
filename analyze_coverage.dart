import 'dart:io';

void main() {
  final file = File('coverage/lcov.info');
  if (!file.existsSync()) {
    print('❌ No se encontró el archivo de cobertura');
    return;
  }

  final lines = file.readAsLinesSync();

  int totalLines = 0;
  int hitLines = 0;
  int totalFiles = 0;

  Map<String, Map<String, int>> fileStats = {};
  String? currentFile;

  for (String line in lines) {
    if (line.startsWith('SF:')) {
      currentFile = line.substring(3);
      totalFiles++;
      fileStats[currentFile] = {'total': 0, 'hit': 0};
    } else if (line.startsWith('LF:')) {
      int linesFound = int.parse(line.substring(3));
      totalLines += linesFound;
      if (currentFile != null) {
        fileStats[currentFile]!['total'] = linesFound;
      }
    } else if (line.startsWith('LH:')) {
      int linesHit = int.parse(line.substring(3));
      hitLines += linesHit;
      if (currentFile != null) {
        fileStats[currentFile]!['hit'] = linesHit;
      }
    }
  }

  double overallCoverage = totalLines > 0 ? (hitLines / totalLines) * 100 : 0;

  print('📊 REPORTE DE COBERTURA DE TESTS');
  print('══════════════════════════════════════════════════════');
  print('');
  print('🎯 RESUMEN GENERAL:');
  print('   • Archivos analizados: $totalFiles');
  print('   • Líneas totales: $totalLines');
  print('   • Líneas cubiertas: $hitLines');
  print('   • Cobertura general: ${overallCoverage.toStringAsFixed(2)}%');
  print('');

  // Determinar el nivel de cobertura
  String level;
  String emoji;
  if (overallCoverage >= 95) {
    level = 'EXCELENTE';
    emoji = '🏆';
  } else if (overallCoverage >= 90) {
    level = 'MUY BUENA';
    emoji = '🥇';
  } else if (overallCoverage >= 80) {
    level = 'BUENA';
    emoji = '👍';
  } else if (overallCoverage >= 70) {
    level = 'ACEPTABLE';
    emoji = '⚠️';
  } else {
    level = 'INSUFICIENTE';
    emoji = '❌';
  }

  print('$emoji CALIFICACIÓN: $level');
  print('');

  print('📁 COBERTURA POR ARCHIVO:');
  print('');

  fileStats.forEach((file, stats) {
    String fileName = file.split('/').last;
    double fileCoverage = stats['total']! > 0 ? (stats['hit']! / stats['total']!) * 100 : 0;
    String fileEmoji = fileCoverage >= 90 ? '✅' : fileCoverage >= 70 ? '⚠️' : '❌';

    print('   $fileEmoji $fileName');
    print('      Líneas: ${stats['hit']}/${stats['total']} (${fileCoverage.toStringAsFixed(1)}%)');
  });

  print('');
  print('🎯 ANÁLISIS DE CALIDAD:');

  if (overallCoverage >= 90) {
    print('   ✅ Excelente cobertura de tests');
    print('   ✅ Código bien protegido contra regresiones');
    print('   ✅ Listo para producción');
  } else if (overallCoverage >= 80) {
    print('   👍 Buena cobertura de tests');
    print('   ⚠️  Considerar añadir más tests para casos edge');
  } else {
    print('   ❌ Cobertura insuficiente');
    print('   🔧 Se requieren más tests antes de producción');
  }

  print('');
  print('🚀 RECOMENDACIONES:');

  if (overallCoverage >= 95) {
    print('   • Mantener el nivel actual de cobertura');
    print('   • Considerar tests de mutación para mayor robustez');
  } else if (overallCoverage >= 90) {
    print('   • Objetivo: alcanzar 95%+ de cobertura');
    print('   • Enfocarse en casos edge no cubiertos');
  } else {
    print('   • Prioridad: aumentar cobertura a 90%+');
    print('   • Añadir tests para líneas no cubiertas');
    print('   • Revisar casos de error no testeados');
  }
}